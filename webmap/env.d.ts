/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_PARAMETERS_URL: string
  readonly VITE_STYLE_URL: string
}

interface ImportMeta {
  readonly env: ImportMetaEnv
}

declare module 'vuetify/lib/util/colors'
