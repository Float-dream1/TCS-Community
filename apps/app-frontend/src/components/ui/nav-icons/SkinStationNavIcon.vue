<template>
    <NavIconSvg :motion="motion">
        <g class="skin-shirt">
            <path d="M9 3.5h6l4.5 2.6-2 4-1.5-0.9V21h-8V9.2l-1.5 0.9-2-4z" />
        </g>
    </NavIconSvg>
</template>

<script setup lang="ts">
import { bob, frames, type NavIconMotion } from './motion'
import NavIconSvg from './NavIconSvg.vue'

/** The shirt sways a little while hovered, like cloth on a hanger. */
const sway = frames(
    'transform',
    [
        [0, 'rotate(0deg)'],
        [0.35, 'rotate(-4deg)', 'ease-in-out'],
        [0.7, 'rotate(2.5deg)', 'ease-in-out'],
        [1, 'rotate(0deg)'],
    ],
    'ease-out',
)

/** A click squashes the shirt, then it springs back. */
const press = frames(
    'transform',
    [
        [0, 'scale(1, 1)'],
        [0.16, 'scale(1.14, 0.84)'],
        [0.44, 'scale(0.95, 1.07)'],
        [0.72, 'scale(1.02, 0.99)'],
        [1, 'scale(1, 1)'],
    ],
    'ease-out',
)

const motion: NavIconMotion = {
    '.skin-shirt': {
        enter: { keyframes: sway, duration: 640 },
        idle: { keyframes: bob((y) => `translateY(${y}px)`, -1), duration: 1400, delay: 600 },
        activate: { keyframes: press, duration: 520 },
    },
}
</script>

<style scoped>
.skin-shirt {
    transform-origin: 12px 4px;
}
</style>
