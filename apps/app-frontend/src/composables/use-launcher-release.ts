import { getVersion } from '@tauri-apps/api/app'
import { computed, ref } from 'vue'

import { AxolotlBrandConfig } from '@/config'

/**
 * This fork ships without the Rust updater: nothing is downloaded or applied in
 * place. All we do here is ask the community repository whether a newer release
 * exists and, if so, point the player at the download page so they can grab it
 * themselves.
 */
const RELEASE_API_URL = 'https://api.github.com/repos/Float-dream1/TCS-Community/releases/latest'
const CHECK_INTERVAL_MS = 6 * 60 * 60 * 1000
const SKIPPED_VERSION_KEY = 'tcs-launcher-skipped-release'

export type LauncherRelease = {
    version: string
    url: string
}

const availableRelease = ref<LauncherRelease | null>(null)
const currentVersion = ref<string>('')
const skippedVersion = ref<string>(readSkippedVersion())

let checkStarted = false
let checkHandle: ReturnType<typeof setInterval> | null = null

function readSkippedVersion(): string {
    try {
        return localStorage.getItem(SKIPPED_VERSION_KEY) ?? ''
    } catch {
        return ''
    }
}

export function normalizeVersion(value: string): string {
    return value.trim().replace(/^v/i, '').split('+')[0]
}

export function isNewerVersion(candidate: string, current: string): boolean {
    const parse = (value: string) =>
        normalizeVersion(value)
            .split('.')
            .map((part) => Number.parseInt(part, 10) || 0)

    const candidateParts = parse(candidate)
    const currentParts = parse(current)

    for (let index = 0; index < Math.max(candidateParts.length, currentParts.length); index++) {
        const left = candidateParts[index] ?? 0
        const right = currentParts[index] ?? 0
        if (left !== right) {
            return left > right
        }
    }

    return false
}

async function fetchLatestRelease(): Promise<LauncherRelease | null> {
    const response = await fetch(RELEASE_API_URL, {
        headers: { Accept: 'application/vnd.github+json' },
    })

    if (!response.ok) {
        return null
    }

    const body = (await response.json()) as { tag_name?: string; html_url?: string }
    if (!body.tag_name) {
        return null
    }

    return {
        version: normalizeVersion(body.tag_name),
        url: body.html_url ?? `${AxolotlBrandConfig.repositoryUrl}/releases/latest`,
    }
}

export async function checkLauncherRelease(): Promise<void> {
    try {
        if (!currentVersion.value) {
            currentVersion.value = normalizeVersion(await getVersion())
        }

        const release = await fetchLatestRelease()
        if (!release || !isNewerVersion(release.version, currentVersion.value)) {
            availableRelease.value = null
            return
        }

        availableRelease.value = release.version === skippedVersion.value ? null : release
    } catch (error) {
        // Offline, rate limited or blocked: stay quiet, this is a courtesy check.
        console.warn('Failed to check for a newer launcher release', error)
    }
}

export function startLauncherReleaseChecks(): void {
    if (checkStarted) {
        return
    }

    checkStarted = true
    void checkLauncherRelease()
    checkHandle = setInterval(() => void checkLauncherRelease(), CHECK_INTERVAL_MS)
}

export function stopLauncherReleaseChecks(): void {
    if (checkHandle !== null) {
        clearInterval(checkHandle)
        checkHandle = null
    }
    checkStarted = false
}

export function skipLauncherRelease(version: string): void {
    skippedVersion.value = version
    availableRelease.value = null

    try {
        localStorage.setItem(SKIPPED_VERSION_KEY, version)
    } catch {
        // Storage unavailable: the skip simply does not persist.
    }
}

export function useLauncherRelease() {
    const latestVersion = computed(() => availableRelease.value?.version ?? '')

    return {
        availableRelease,
        currentVersion,
        latestVersion,
        skipRelease: skipLauncherRelease,
    }
}
