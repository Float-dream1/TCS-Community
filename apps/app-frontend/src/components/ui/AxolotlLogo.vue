<template>
    <div
        aria-label="TaCraft Socially"
        class="flex h-full items-center gap-2 font-extrabold text-[var(--color-text-primary)]"
    >
        <img aria-hidden="true" class="aspect-square h-full object-contain" :src="axolotlVisual" />
        <span v-if="!iconOnly" class="hidden text-sm tracking-wide xl:inline"
            >TaCraft Socially</span
        >
    </div>
</template>

<script setup lang="ts">
import axolotlVisual from '@modrinth/assets/branding/tacraft.png'

defineProps<{
    iconOnly?: boolean
}>()
</script>
