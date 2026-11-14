<script setup lang="ts">
import { ExternalIcon, ScaleIcon } from '@modrinth/assets'
import { Button, defineMessages, useVIntl } from '@modrinth/ui'
import { getVersion } from '@tauri-apps/api/app'
import { inject, onMounted, ref } from 'vue'

import { AxolotlBrandConfig } from '@/config'

import SettingsSection from './SettingsSection.vue'

const { formatMessage } = useVIntl()
const version = ref('')
const replayOobe = inject<() => void>('replayOobe')

const licenseUrl = `${AxolotlBrandConfig.repositoryUrl}/blob/main/LICENSE`
const copyingUrl = `${AxolotlBrandConfig.repositoryUrl}/blob/main/COPYING.md`
const thirdPartyLicensesUrl = `${AxolotlBrandConfig.repositoryUrl}/tree/main/third-party/licenses`

onMounted(() => {
    void getVersion()
        .then((resolved) => {
            version.value = resolved
        })
        .catch(() => {
            // keep empty version string; do not fail the settings category
        })
})

const messages = defineMessages({
    productTitle: {
        id: 'app.settings.about.product-title',
        defaultMessage: 'About {productName}',
    },
    productDescription: {
        id: 'app.settings.about.description',
        defaultMessage: 'Your last launcher.',
    },
    version: {
        id: 'app.settings.about.version',
        defaultMessage: 'Version {version}',
    },
    replayOobe: {
        id: 'app.settings.about.replay-oobe',
        defaultMessage: 'Run first-time setup again',
    },
    licenseAttribution: {
        id: 'app.settings.about.license-attribution',
        defaultMessage: 'License & attribution',
    },
    attribution: {
        id: 'app.settings.about.attribution',
        defaultMessage:
            'TaCraft Player Community is a modified version of the open-source Modrinth codebase.',
    },
    notAffiliated: {
        id: 'app.settings.about.not-affiliated',
        defaultMessage:
            'Modrinth is a trademark of Rinth, Inc. TaCraft Player Community is not affiliated with or endorsed by Rinth, Inc.',
    },
    originalSource: {
        id: 'app.settings.about.original-source',
        defaultMessage: 'Original Modrinth source',
    },
    projectLicense: {
        id: 'app.settings.about.project-license',
        defaultMessage: 'Project license (GPL-3.0)',
    },
    copyingGuidelines: {
        id: 'app.settings.about.copying-guidelines',
        defaultMessage: 'Copying guidelines',
    },
    thirdPartyLicenses: {
        id: 'app.settings.about.third-party-licenses',
        defaultMessage: 'Third-party licenses',
    },
})
</script>

<template>
    <div class="about-page flex flex-col gap-6">
        <section id="settings-target-about-product" tabindex="-1" class="about-panel">
            <div class="min-w-0 text-center">
                <h2 class="m-0 text-xl font-semibold text-[var(--color-text-primary)]">
                    {{
                        formatMessage(messages.productTitle, {
                            productName: AxolotlBrandConfig.productName,
                        })
                    }}
                </h2>
                <p class="m-0 mt-1 text-[var(--color-text-tertiary)]">
                    {{ formatMessage(messages.version, { version }) }}
                </p>
                <p class="m-0 mt-3 text-center text-[var(--color-text-default)]">
                    {{ formatMessage(messages.productDescription) }}
                </p>
            </div>
        </section>

        <SettingsSection>
            <template #header>
                <h3
                    class="m-0 flex items-center gap-2 text-base font-semibold text-[var(--color-text-primary)]"
                >
                    <ScaleIcon class="size-5 text-[var(--color-text-tertiary)]" />
                    {{ formatMessage(messages.licenseAttribution) }}
                </h3>
            </template>
            <div class="flex flex-col gap-3 p-4">
                <p class="m-0 text-[var(--color-text-default)]">
                    {{ formatMessage(messages.attribution) }}
                </p>
                <p class="m-0 mt-2 text-sm text-[var(--color-text-tertiary)]">
                    {{ formatMessage(messages.notAffiliated) }}
                </p>
                <div class="mt-3 flex flex-wrap gap-2">
                    <a
                        :href="licenseUrl"
                        target="_blank"
                        rel="noopener noreferrer"
                        class="inline-flex items-center gap-2 rounded-lg bg-surface-4 px-3 py-2 text-sm font-semibold text-[var(--color-text-primary)] transition-colors hover:bg-surface-5"
                    >
                        {{ formatMessage(messages.projectLicense) }}
                        <ExternalIcon class="size-4 text-[var(--color-text-tertiary)]" />
                    </a>
                    <a
                        :href="copyingUrl"
                        target="_blank"
                        rel="noopener noreferrer"
                        class="inline-flex items-center gap-2 rounded-lg bg-surface-4 px-3 py-2 text-sm font-semibold text-[var(--color-text-primary)] transition-colors hover:bg-surface-5"
                    >
                        {{ formatMessage(messages.copyingGuidelines) }}
                        <ExternalIcon class="size-4 text-[var(--color-text-tertiary)]" />
                    </a>
                    <a
                        :href="thirdPartyLicensesUrl"
                        target="_blank"
                        rel="noopener noreferrer"
                        class="inline-flex items-center gap-2 rounded-lg bg-surface-4 px-3 py-2 text-sm font-semibold text-[var(--color-text-primary)] transition-colors hover:bg-surface-5"
                    >
                        {{ formatMessage(messages.thirdPartyLicenses) }}
                        <ExternalIcon class="size-4 text-[var(--color-text-tertiary)]" />
                    </a>
                    <a
                        href="https://github.com/modrinth/code"
                        target="_blank"
                        rel="noopener noreferrer"
                        class="inline-flex items-center gap-2 rounded-lg bg-surface-4 px-3 py-2 text-sm font-semibold text-[var(--color-text-primary)] transition-colors hover:bg-surface-5"
                    >
                        {{ formatMessage(messages.originalSource) }}
                        <ExternalIcon class="size-4 text-[var(--color-text-tertiary)]" />
                    </a>
                </div>
            </div>
        </SettingsSection>

        <div id="settings-target-about-replay-oobe" tabindex="-1" class="flex flex-wrap gap-2">
            <Button type="base" @click="replayOobe?.()">
                {{ formatMessage(messages.replayOobe) }}
            </Button>
        </div>
    </div>
</template>

<style scoped>
.about-panel {
    padding: 1.25rem;
    border: 1px solid var(--surface-4);
    border-radius: var(--radius-md);
    background: var(--surface-3);
}
</style>
