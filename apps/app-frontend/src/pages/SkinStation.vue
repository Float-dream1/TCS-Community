<script setup lang="ts">
// The community skin site is an external app, so it is embedded as a page.
import EmbeddedSitePage from '@/components/ui/embedded-site/EmbeddedSitePage.vue'

defineOptions({ name: 'SkinStation' })

const SKIN_STATION_URL = 'https://tcsskins.tcscraft.com/'
</script>

<template>
    <EmbeddedSitePage :src="SKIN_STATION_URL" />
</template>
