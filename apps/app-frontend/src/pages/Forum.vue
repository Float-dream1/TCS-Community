<script setup lang="ts">
// This page embeds the community forum, so this fork has its own entry point in
// the navigation rail instead of a truly empty route.
import EmbeddedSitePage from '@/components/ui/embedded-site/EmbeddedSitePage.vue'

defineOptions({ name: 'Forum' })

const COMMUNITY_URL = 'https://www.tcscraft.com/all'
</script>

<template>
    <EmbeddedSitePage :src="COMMUNITY_URL" />
</template>
