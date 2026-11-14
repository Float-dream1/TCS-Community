import { expect, it } from 'vitest'

import { getVisibleSettingsCategoryDefinitions } from '@/components/ui/settings/settings-category-definitions'

import { resolveSettingsRoute } from './deep-links'

it('falls back to the default screen for an OAuth callback to a removed settings page', () => {
    expect(resolveSettingsRoute('third-party-accounts')).toEqual({
        path: '/settings',
        hash: '#interface',
        entry: undefined,
    })
})

it('allows every public settings category from the navigation registry', () => {
    for (const category of getVisibleSettingsCategoryDefinitions(false)) {
        expect(resolveSettingsRoute(category.id).hash).toBe(`#${category.id}`)
    }
})

it('keeps unknown and developer-only settings links on the default screen', () => {
    expect(resolveSettingsRoute('unknown').hash).toBe('#interface')
    expect(resolveSettingsRoute('feature-flags').hash).toBe('#interface')
})
