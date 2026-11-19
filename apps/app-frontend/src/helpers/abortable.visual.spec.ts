import { expect, it, vi } from 'vitest'

import { abortable } from './abortable'

vi.mock('@tauri-apps/api/core', () => ({ invoke: vi.fn() }))
vi.mock('@tauri-apps/api/event', () => ({ listen: vi.fn() }))

it('rejects at once on abort and hands the pending request to onAbort', async () => {
    const request = new Promise<string>(() => {})
    const onAbort = vi.fn()
    const controller = new AbortController()
    const waiting = abortable(request, controller.signal, onAbort)
    controller.abort()
    await expect(waiting).rejects.toMatchObject({ name: 'AbortError' })
    expect(onAbort).toHaveBeenCalledExactlyOnceWith(request)
})

it('treats an already aborted signal as an abort instead of waiting', async () => {
    const controller = new AbortController()
    controller.abort()
    const onAbort = vi.fn()
    await expect(
        abortable(new Promise(() => {}), controller.signal, onAbort),
    ).rejects.toMatchObject({ name: 'AbortError' })
    expect(onAbort).toHaveBeenCalledOnce()
})
