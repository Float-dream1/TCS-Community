<script setup lang="ts">
// This page embeds the community forum, so this fork has its own entry point in
// the navigation rail instead of a truly empty route.
defineOptions({ name: 'Forum' })

const COMMUNITY_URL = 'https://www.tcscraft.com/all'
</script>

<template>
    <div class="box-border h-full">
        <iframe
            :src="COMMUNITY_URL"
            class="h-full w-full border-0"
            allow="clipboard-read; clipboard-write"
        />
    </div>
</template>
