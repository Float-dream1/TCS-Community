<script setup lang="ts">
// The forum and the skin station are separate web apps, so both navigation
// entries embed one of them instead of rendering a launcher page of their own.
defineProps<{
    src: string
}>()
</script>

<template>
    <div class="box-border h-full">
        <iframe :src="src" class="h-full w-full border-0" allow="clipboard-read; clipboard-write" />
    </div>
</template>
