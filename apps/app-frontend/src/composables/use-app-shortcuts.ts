import {
    bindingMatchesKeyboardEvent,
    bindingMatchesMouseEvent,
    bindingMatchesWheelEvent,
    type KeyBinding,
    useModalStack,
} from '@modrinth/ui'
import { computed, nextTick, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'

import { useNetworkStatus } from '@/composables/useNetworkStatus'
import { SHORTCUT_ACTIONS, type ShortcutAction } from '@/helpers/shortcut-actions'
import { useTheming } from '@/store/state'

/**
 * Launcher-wide keyboard, pointer and wheel shortcuts.
 *
 * Everything lives here so `App.vue` only has to start and stop it: while a
 * dialog is open the shortcuts stand aside, and editing surfaces keep their own
 * keys. Scrolling actions move the page's own scroller rather than whichever
 * element happens to hold focus.
 */
export function useAppShortcuts() {
    const themeStore = useTheming()
    const { hasModal } = useModalStack()
    const router = useRouter()
    const route = useRoute()
    const { offline } = useNetworkStatus()

    /**
     * Keep browser/webview shortcuts from escaping the launcher UI. F12 remains
     * available when the in-app developer mode is enabled so development tools
     * can still be opened intentionally.
     */
    function handleGlobalKeydown(event: KeyboardEvent) {
        const key = event.key.toLowerCase()
        const isFindShortcut = key === 'f' && (event.ctrlKey || event.metaKey)
        const isBlockedDevtoolsShortcut = event.key === 'F12' && !themeStore.devMode

        if (isFindShortcut || isBlockedDevtoolsShortcut) {
            event.preventDefault()
            event.stopPropagation()
        }

        handleScrollShortcutKey(event)
        handleNavShortcutKey(event)
    }

    /** Editing surfaces keep these keys for themselves. */
    function isEditableTarget(target: EventTarget | null) {
        return (
            target instanceof HTMLInputElement ||
            target instanceof HTMLTextAreaElement ||
            target instanceof HTMLSelectElement ||
            (target instanceof HTMLElement && target.isContentEditable)
        )
    }

    function scrollsAtOwnLevel(element: Element) {
        const { overflowY } = getComputedStyle(element)
        return (
            /(auto|scroll|overlay)/.test(overflowY) && element.scrollHeight > element.clientHeight
        )
    }

    /** A container that scrolls the page itself rather than a widget on it. */
    function isPageScroller(element: Element) {
        return scrollsAtOwnLevel(element) && element.clientHeight >= window.innerHeight / 2
    }

    /** Nearest scrolling ancestor, whatever its size. */
    function nearestScrollContainer(target: EventTarget | null) {
        let element = target instanceof Element ? target : null
        while (element) {
            if (scrollsAtOwnLevel(element)) return element
            element = element.parentElement
        }
        return null
    }

    /**
     * The page's own scroller. Most pages scroll inside `.app-viewport`, but some
     * screens (settings, consoles, studios) turn that element's scrolling off and
     * host a full-height container inside it, so fall back to whatever fills the
     * middle of the viewport.
     */
    function resolvePageScroller(): HTMLElement | null {
        const viewport = document.querySelector<HTMLElement>('.app-viewport')
        if (!viewport) return null
        if (isPageScroller(viewport)) return viewport

        const bounds = viewport.getBoundingClientRect()
        let element: Element | null = document.elementFromPoint(
            bounds.left + bounds.width / 2,
            bounds.top + bounds.height / 2,
        )
        while (element) {
            if (element instanceof HTMLElement && isPageScroller(element)) return element
            element = element.parentElement
        }

        return viewport
    }

    /** The combination an action answers to now: recorded if there is one, default otherwise. */
    function bindingFor(action: ShortcutAction): KeyBinding {
        return themeStore.shortcutBindings[action.id] ?? action.defaultBinding
    }

    /** Whether an action is switched on and reachable in the current state. */
    function shortcutIsAvailable(action: ShortcutAction): boolean {
        if (!themeStore[action.enabledField]) return false
        return !action.unavailable?.({
            worldsTabEnabled: themeStore.featureFlags.worlds_tab,
            offline: offline.value,
        })
    }

    /**
     * Finds the action a combination belongs to. Shortcuts stand down entirely
     * while a dialog is open, so the one being recorded cannot fire, and editing
     * surfaces keep their keys. `includeDisabled` is for scrolling, which has to
     * recognise its keys even while it is off in order to hold them back.
     */
    function findShortcut<E extends Event>(
        event: E,
        matches: (binding: KeyBinding, event: E) => boolean,
        { includeDisabled = false }: { includeDisabled?: boolean } = {},
    ): ShortcutAction | null {
        if (hasModal.value) return null
        if (isEditableTarget(event.target)) return null

        for (const action of SHORTCUT_ACTIONS) {
            if (!includeDisabled && !shortcutIsAvailable(action)) continue
            if (matches(bindingFor(action), event)) return action
        }

        return null
    }

    /** Does what an action is for. Scrolling actions move the page's own scroller. */
    function runShortcut(action: ShortcutAction, event: Event) {
        if (action.target) {
            router.push(action.target(route))
            return
        }

        const focusedContainer = nearestScrollContainer(event.target)
        if (focusedContainer && !isPageScroller(focusedContainer)) return

        const scroller = resolvePageScroller()
        if (!scroller) return

        action.applyScroll?.(scroller)
    }

    /**
     * Quick scrolling for the page's own scroll container. The setting decides
     * whether the keys act at all: while it is off they stay inert, and while it is
     * on they move the page. A focused list or popover still scrolls itself, so
     * local keyboard scrolling keeps working.
     */
    function handleScrollShortcutKey(event: KeyboardEvent) {
        if (event.isComposing) return

        const match = findShortcut(event, bindingMatchesKeyboardEvent, { includeDisabled: true })
        if (match?.group !== 'scroll') return

        const focusedContainer = nearestScrollContainer(event.target)
        if (focusedContainer && !isPageScroller(focusedContainer)) return

        const scroller = resolvePageScroller()
        if (!scroller) return

        // Take the key over even when the feature is off: the browser would scroll
        // a focused page container on its own, which would make the setting a lie.
        event.preventDefault()
        if (!shortcutIsAvailable(match)) return

        match.applyScroll?.(scroller)
    }

    /**
     * Jump to a menu item with the combination it is set to. Every shortcut is off
     * by default and enabled individually from the Shortcut settings page.
     */
    function handleNavShortcutKey(event: KeyboardEvent) {
        if (event.isComposing) return

        const match = findShortcut(event, bindingMatchesKeyboardEvent)
        if (match?.group !== 'nav') return

        event.preventDefault()
        runShortcut(match, event)
    }

    /** Whether any action listens to the pointer, so the listeners can stay cheap. */
    const hasPointerBindings = computed(() =>
        SHORTCUT_ACTIONS.some((action) => bindingFor(action).device === 'mouse'),
    )

    function handleShortcutMouse(event: MouseEvent) {
        if (!hasPointerBindings.value) return

        const match = findShortcut(event, bindingMatchesMouseEvent)
        if (!match) return

        // A shortcut owns this button, so the pointer event stops here.
        event.preventDefault()
        event.stopPropagation()
        runShortcut(match, event)
    }

    function handleShortcutWheel(event: WheelEvent) {
        if (!hasPointerBindings.value) return

        const match = findShortcut(event, bindingMatchesWheelEvent)
        if (!match) return

        event.preventDefault()
        event.stopPropagation()
        runShortcut(match, event)
    }

    /**
     * Hand the keyboard over to the page after the menu navigates. Without this the
     * focus stays on the nav button, so Tab keeps walking the rail and the page's
     * own shortcuts act on whatever happened to be focused before.
     */
    function stopRouteFocusWatch() {
        return watch(
            () => route.path,
            async () => {
                await nextTick()
                const active = document.activeElement
                const navRail = document.querySelector('.app-grid-navbar')
                const cameFromMenu =
                    !active || active === document.body || (navRail?.contains(active) ?? false)
                if (!cameFromMenu) return
                document.querySelector<HTMLElement>('.app-viewport')?.focus({ preventScroll: true })
            },
        )
    }

    let stopFocusWatch: (() => void) | null = null

    function start() {
        window.addEventListener('keydown', handleGlobalKeydown, true)
        window.addEventListener('mousedown', handleShortcutMouse, true)
        // Not passive: a bound wheel direction has to keep the page from scrolling.
        window.addEventListener('wheel', handleShortcutWheel, { capture: true, passive: false })
        stopFocusWatch?.()
        stopFocusWatch = stopRouteFocusWatch()
    }

    function stop() {
        window.removeEventListener('keydown', handleGlobalKeydown, true)
        window.removeEventListener('mousedown', handleShortcutMouse, true)
        window.removeEventListener('wheel', handleShortcutWheel, { capture: true })
        stopFocusWatch?.()
        stopFocusWatch = null
    }

    /**
     * Whether a pointer button belongs to a shortcut. `App.vue` asks before it
     * turns a middle click into a left click, so the bound action wins instead
     * of the page opening a new tab behind it.
     */
    function matchesPointerShortcut(event: MouseEvent) {
        return Boolean(findShortcut(event, bindingMatchesMouseEvent))
    }

    return { start, stop, matchesPointerShortcut }
}
