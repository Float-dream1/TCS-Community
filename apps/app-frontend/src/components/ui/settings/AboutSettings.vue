<script setup lang="ts">
import { ExternalIcon, ScaleIcon, XIcon } from '@modrinth/assets'
import { Button, defineMessages, useVIntl } from '@modrinth/ui'
import { getVersion } from '@tauri-apps/api/app'
import { inject, onMounted, ref } from 'vue'

import { AxolotlBrandConfig } from '@/config'
import { EASTER_EGG_LINES } from '@/data/easter-egg-lines'

import SettingsSection from './SettingsSection.vue'

const { formatMessage } = useVIntl()
const version = ref('')
const replayOobe = inject<() => void>('replayOobe')

const eggLine = ref<string | null>(null)

function rollEasterEgg() {
    // Math.random is fine here: the pick is cosmetic and never needs to be
    // reproducible across launches.
    eggLine.value = EASTER_EGG_LINES[Math.floor(Math.random() * EASTER_EGG_LINES.length)]
}

function closeEasterEgg() {
    eggLine.value = null
}

const repositoryUrl = AxolotlBrandConfig.repositoryUrl
// The repository has no standalone LICENSE file; the GPL-3.0 text lives upstream.
const licenseUrl = 'https://www.gnu.org/licenses/gpl-3.0.html'
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
            'TCS-Community is a modified version of the open-source Axolotl Launcher project.',
    },
    notAffiliated: {
        id: 'app.settings.about.not-affiliated',
        defaultMessage:
            'Modrinth is a trademark of Rinth, Inc. TCS-Community is not affiliated with or endorsed by Rinth, Inc.',
    },
    sourceRepository: {
        id: 'app.settings.about.source-repository',
        defaultMessage: 'Source repository',
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
    easterEgg: {
        id: 'app.settings.about.easter-egg',
        defaultMessage: 'Easter egg',
    },
    closeEasterEgg: {
        id: 'app.settings.about.easter-egg-close',
        defaultMessage: 'Close',
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
                        :href="repositoryUrl"
                        target="_blank"
                        rel="noopener noreferrer"
                        class="inline-flex items-center gap-2 rounded-lg bg-surface-4 px-3 py-2 text-sm font-semibold text-[var(--color-text-primary)] transition-colors hover:bg-surface-5"
                    >
                        {{ formatMessage(messages.sourceRepository) }}
                        <ExternalIcon class="size-4 text-[var(--color-text-tertiary)]" />
                    </a>
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
            <Button type="base" @click="rollEasterEgg">
                {{ formatMessage(messages.easterEgg) }}
            </Button>
        </div>

        <Teleport to="body">
            <div v-if="eggLine !== null" class="egg-backdrop" @click.self="closeEasterEgg">
                <div class="egg-card" role="dialog" aria-modal="true">
                    <button
                        type="button"
                        class="egg-close"
                        :aria-label="formatMessage(messages.closeEasterEgg)"
                        @click="closeEasterEgg"
                    >
                        <XIcon class="size-4" />
                    </button>
                    <p class="egg-text">{{ eggLine }}</p>
                </div>
            </div>
        </Teleport>
    </div>
</template>

<style scoped>
.egg-backdrop {
    position: fixed;
    inset: 0;
    z-index: 100;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 1.5rem;
    background: color-mix(in srgb, var(--color-bg) 70%, transparent);
    backdrop-filter: blur(2px);
}

.egg-card {
    position: relative;
    width: min(24rem, 100%);
    padding: 2.5rem 1.5rem 1.75rem;
    border: 1px solid var(--surface-4);
    border-radius: var(--radius-md);
    background: var(--surface-3);
    box-shadow: var(--shadow-floating, 0 12px 32px rgb(0 0 0 / 25%));
}

.egg-close {
    position: absolute;
    top: 0.5rem;
    left: 0.5rem;
    display: flex;
    align-items: center;
    justify-content: center;
    width: 1.75rem;
    height: 1.75rem;
    color: var(--color-text-tertiary);
    border-radius: var(--radius-sm);
    transition:
        background-color 0.15s ease,
        color 0.15s ease;
}

.egg-close:hover {
    color: var(--color-text-primary);
    background: var(--surface-4);
}

.egg-text {
    margin: 0;
    color: var(--color-text-primary);
    font-size: 1rem;
    line-height: 1.6;
    text-align: center;
    word-break: break-word;
}

.about-panel {
    padding: 1.25rem;
    border: 1px solid var(--surface-4);
    border-radius: var(--radius-md);
    background: var(--surface-3);
}
</style>
