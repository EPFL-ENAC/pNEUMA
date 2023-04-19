<script setup lang="ts">
import JsonWebMap from '@/components/JsonWebMap.vue'

const parametersUrl = import.meta.env.VITE_PARAMETERS_URL
const styleUrl = import.meta.env.VITE_STYLE_URL
</script>

<template>
  <JsonWebMap :parameters-url="parametersUrl" :style-url="styleUrl" />
</template>
