<script setup lang="ts">
import 'maplibre-gl/dist/maplibre-gl.css'

import {
  FullscreenControl,
  GeolocateControl,
  Map,
  NavigationControl,
  Popup,
  ScaleControl,
  type LngLatLike,
  type StyleSpecification
} from 'maplibre-gl'
import { onMounted, ref, watch } from 'vue'

defineExpose({
  update
})
const props = withDefaults(
  defineProps<{
    styleSpec: string | StyleSpecification
    center?: LngLatLike
    zoom?: number
    aspectRatio?: number
    minZoom?: number
    maxZoom?: number
    filterIds?: string[]
    popupLayerIds?: string[]
    areaLayerIds?: string[]
  }>(),
  {
    center: undefined,
    zoom: 12,
    aspectRatio: undefined,
    minZoom: undefined,
    maxZoom: undefined,
    filterIds: undefined,
    popupLayerIds: () => [],
    areaLayerIds: () => []
  }
)

const loading = ref(true)
let map: Map | undefined = undefined

onMounted(() => {
  map = new Map({
    container: 'maplibre-map',
    style: props.styleSpec,
    center: props.center,
    zoom: props.zoom
  })
  map.addControl(new NavigationControl({}))
  map.addControl(new GeolocateControl({}))
  map.addControl(new ScaleControl({}))
  map.addControl(new FullscreenControl({}))

  map.once('load', () => {
    filterLayers(props.filterIds)
  })
  loading.value = false
})

watch(
  () => props.styleSpec,
  (styleSpec) => {
    map?.setStyle(styleSpec)
  },
  { immediate: true }
)
watch(
  () => props.popupLayerIds,
  (popupLayerIds) => {
    popupLayerIds.forEach((layerId) => {
      const popup = new Popup({
        closeButton: false,
        closeOnClick: false
      })
      map?.on('mouseenter', layerId, function (e) {
        if (map) {
          map.getCanvas().style.cursor = 'pointer'
          popup
            .setLngLat(e.lngLat)
            .setHTML(
              Object.entries(e.features?.at(0)?.properties ?? {})
                .map(([key, value]) => `<strong>${key}:</strong> ${value}`)
                .join('<br>')
            )
            .addTo(map)
        }
      })
      map?.on('mouseleave', layerId, function () {
        if (map) {
          map.getCanvas().style.cursor = ''
        }
        popup.remove()
      })
    })
  },
  { immediate: true }
)
watch(
  () => props.filterIds,
  (filterIds) => filterLayers(filterIds),
  { immediate: true }
)

function update(center?: LngLatLike, zoom?: number) {
  if (center !== undefined) {
    map?.setCenter(center)
  }
  if (zoom !== undefined) {
    map?.setZoom(zoom)
  }
}

function filterLayers(filterIds?: string[]) {
  if (filterIds) {
    map
      ?.getStyle()
      .layers.filter((layer) => !layer.id.startsWith('gl-draw'))
      .forEach((layer) => {
        map?.setLayoutProperty(
          layer.id,
          'visibility',
          filterIds.includes(layer.id) ? 'visible' : 'none'
        )
      })
  }
}
</script>

<template>
  <v-progress-linear v-if="loading" active color="primary" indeterminate />
  <v-responsive :aspect-ratio="aspectRatio" height="100%">
    <div id="maplibre-map" />
  </v-responsive>
</template>

<style scoped>
#maplibre-map {
  height: 100%;
}
</style>
