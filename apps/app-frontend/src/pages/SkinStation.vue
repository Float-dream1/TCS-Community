<script setup lang="ts">
// The community skin site is an external app, so it is embedded as a page.
defineOptions({ name: 'SkinStation' })

const SKIN_STATION_URL = 'https://tcsskins.tcscraft.com/'
</script>

<template>
    <div class="box-border h-full">
        <iframe
            :src="SKIN_STATION_URL"
            class="h-full w-full border-0"
            allow="clipboard-read; clipboard-write"
        />
    </div>
</template>
