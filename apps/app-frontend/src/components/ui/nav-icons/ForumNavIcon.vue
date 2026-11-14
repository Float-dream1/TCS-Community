<template>
    <NavIconSvg :motion="motion">
        <g class="forum-bubble">
            <path d="M4 4.5h16v11h-9.5L4 20.5z" />
            <line class="forum-line" x1="8" y1="8.5" x2="16" y2="8.5" pathLength="1" />
            <line class="forum-line" x1="8" y1="12" x2="13" y2="12" pathLength="1" />
        </g>
    </NavIconSvg>
</template>

<script setup lang="ts">
import { bob, frames, type NavIconMotion, redraw } from './motion'
import NavIconSvg from './NavIconSvg.vue'

/** The bubble lifts and settles, like a message popping in. */
const lift = frames(
    'transform',
    [
        [0, 'translateY(0)'],
        [0.3, 'translateY(-3px)', 'ease-in'],
        [0.6, 'translateY(0.6px)'],
        [1, 'translateY(0)'],
    ],
    'ease-out',
)

/** A click presses the bubble flat, then it springs back. */
const press = frames(
    'transform',
    [
        [0, 'scale(1, 1)'],
        [0.16, 'scale(1.16, 0.82)'],
        [0.44, 'scale(0.94, 1.09)'],
        [0.72, 'scale(1.03, 0.98)'],
        [1, 'scale(1, 1)'],
    ],
    'ease-out',
)

const motion: NavIconMotion = {
    '.forum-bubble': {
        enter: { keyframes: lift, duration: 620 },
        idle: { keyframes: bob((y) => `translateY(${y}px)`, -1), duration: 1200, delay: 560 },
        activate: { keyframes: press, duration: 520 },
    },
    '.forum-line': { enter: redraw(680) },
}
</script>

<style scoped>
.forum-bubble {
    transform-origin: 12px 20px;
}
</style>
