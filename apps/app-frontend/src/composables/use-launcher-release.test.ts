import { describe, expect, it } from 'vitest'

import { isNewerVersion, normalizeVersion } from './use-launcher-release'

describe('normalizeVersion', () => {
    it('drops the release tag prefix and build metadata', () => {
        expect(normalizeVersion('v1.0.1')).toBe('1.0.1')
        expect(normalizeVersion(' V1.2.3+abc ')).toBe('1.2.3')
    })
})

describe('isNewerVersion', () => {
    it('detects a newer patch release', () => {
        expect(isNewerVersion('1.0.2', '1.0.1')).toBe(true)
    })

    it('detects a newer minor release', () => {
        expect(isNewerVersion('1.1.0', '1.0.9')).toBe(true)
    })

    it('treats equal versions as not newer', () => {
        expect(isNewerVersion('v1.0.1', '1.0.1')).toBe(false)
    })

    it('ignores older releases', () => {
        expect(isNewerVersion('1.0.0', '1.0.1')).toBe(false)
        expect(isNewerVersion('0.9.9', '1.0.0')).toBe(false)
    })

    it('pads missing segments with zero', () => {
        expect(isNewerVersion('1.1', '1.0.9')).toBe(true)
        expect(isNewerVersion('1', '1.0.0')).toBe(false)
    })
})
