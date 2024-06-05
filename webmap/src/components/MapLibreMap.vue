<script setup lang="ts">
import 'maplibre-gl/dist/maplibre-gl.css'
import LoadingCircle from '@/components/LoadingCircle.vue'
import LegendMap from '@/components/LegendMap.vue'

import {
  FullscreenControl,
  Map as Maplibre,
  NavigationControl,
  Popup,
  ScaleControl,
  VectorTileSource,
  type FilterSpecification,
  type LngLatLike,
  type MapSourceDataEvent,
  type StyleSetterOptions,
  type StyleSpecification,
  addProtocol
} from 'maplibre-gl'
import type { LegendColor } from '@/utils/legendColor'
import { onMounted, ref, watch } from 'vue'

import { Protocol } from 'pmtiles'
import { add } from 'lodash'

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
    legendColors?: LegendColor[]
    callbackLoaded?: () => void
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
const container = ref<HTMLDivElement | null>(null)
let map: Maplibre | undefined = undefined
const hasLoaded = ref(false)
const protocol = new Protocol()

const popup = ref<Popup>(
  new Popup({
    closeButton: false,
    maxWidth: '800px'
  })
)

function displaySegmentTime(t0: number, t1: number) {
  // Start time of the recording
  const startTime = new Date('2018-10-24T08:30:00')

  // Calculate the midpoint in milliseconds
  const timestamp = (t0 + t1) / 2

  // Create a new date by adding the midpoint to the start time
  const segmentTime = new Date(startTime.getTime() + timestamp)

  // Format the time as hours:minutes
  let hours = segmentTime.getHours()
  let minutes = segmentTime.getMinutes()

  // Ensuring two-digit minutes format
  const displayMinutes = minutes < 10 ? '0' + minutes : minutes

  // Return the formatted time
  return `${hours}:${displayMinutes}`
}

onMounted(() => {
  addProtocol('pmtiles', protocol.tile)
  map = new Maplibre({
    container: container.value as HTMLDivElement,
    style: props.styleSpec,
    center: props.center,
    zoom: props.zoom,
    minZoom: props.minZoom,
    maxZoom: props.maxZoom,
    attributionControl: false
  })
  // map.showTileBoundaries = true
  map.addControl(new NavigationControl({}))
  map.addControl(new ScaleControl({}))
  map.addControl(
    new FullscreenControl({
      container: document.getElementById('map-time-input-container') ?? undefined
    })
  )

  // filterLayers(props.filterIds)

  let hoveredStateId: number = -1

  map.once('load', () => {
    // filterLayers(props.filterIds)
    if (!map) return
    hasLoaded.value = true
    loading.value = false

    map.on('sourcedata', (e: MapSourceDataEvent) => {
      if (e.isSourceLoaded) loading.value = false
    })

    map.on('sourcedataloading', () => {
      loading.value = true
    })

    map.on('mouseleave', 'trajectories', () => {
      if (hoveredStateId) {
        map?.setFeatureState(
          { source: 'pneuma', sourceLayer: 'trajectories', id: hoveredStateId },
          { hover: false }
        )
      }
      hoveredStateId = -1
      popup.value.remove()
      if (map) map.getCanvas().classList.remove('hovered-feature')
    })

    map.on('mousemove', 'trajectories', function (e) {
      const features = e.features
      if (features && features.length > 0 && map) {
        map.getCanvas().classList.add('hovered-feature')
        const feat = features[0]
        throttle(
          () => {
            const newId = Number(features[0]?.id) || -1

            if (newId !== hoveredStateId) {
              if (hoveredStateId && map !== undefined) {
                map?.setFeatureState(
                  { source: 'pneuma', sourceLayer: 'trajectories', id: hoveredStateId },
                  { hover: false }
                )
              }

              const { speed, acceleration, segment_index, t0, t1, vehicle_type } = feat.properties
              const timestamp = (t0 + t1) / 2
              if (hoveredStateId !== -1)
                popup.value
                  .setLngLat(e.lngLat)
                  .setHTML(
                    `<h3>${vehicle_type} - ${hoveredStateId} at ${displaySegmentTime(t0, t1)}</h3>
                    </br>
                    <div>
                      Speed : <strong>${speed}</strong> km/h
                    </div>
                    <div>
                      Acceleration : <strong>${acceleration.toFixed(2)}</strong> m.s-2
                    </div>
                    
                  `
                  )
                  .addTo(map as Maplibre)

              hoveredStateId = newId

              map?.setFeatureState(
                { source: 'pneuma', sourceLayer: 'trajectories', id: hoveredStateId },
                { hover: true }
              )
            }
          },
          'mouvemove',
          30
        )
      } else if (map) {
        map.getCanvas().classList.remove('hovered-feature')
      }
    })
    if (props.callbackLoaded !== undefined) {
      props.callbackLoaded()
    }
  })
  loading.value = false
})

let throttleTimer = new Map<string, boolean>()

const throttle = (callback: () => void, id: string, time: number) => {
  if (throttleTimer.get(id)) {
    // If currently throttled, exit the function
    return
  }

  // Set the throttle flag
  throttleTimer.set(id, true)

  // Clear the throttle flag after the specified time
  setTimeout(() => {
    throttleTimer.set(id, false)
  }, time)
  callback()
}

const setFilter = (
  layerId: string,
  filter?: FilterSpecification | null | undefined,
  options?: StyleSetterOptions | undefined
) => {
  if (hasLoaded.value) {
    throttle(() => map?.setFilter(layerId, filter, options), layerId + '-filter', 100)
  }
}

const setPaintProperty = (
  layerId: string,
  name: string,
  value: any,
  options?: StyleSetterOptions | undefined
) => {
  if (hasLoaded.value)
    throttle(() => map?.setPaintProperty(layerId, name, value, options), layerId + '-paint', 100)
}

const queryFeatures = (filter: any[]) => {
  return map?.querySourceFeatures('pneuma', {
    sourceLayer: 'trajectories',
    filter: filter as FilterSpecification,
    validate: false
  })
}

const queryRenderedFeatures = () => {
  return map?.queryRenderedFeatures()
}

const onZoom = (callback: () => void) => {
  map?.on('zoom', callback)
}

const changeSourceTilesUrl = (sourceId: string, url: string) => {
  const source = map?.getSource(sourceId) as VectorTileSource
  source.setTiles([url])
}

const getSourceTilesUrl = (sourceId: string) => {
  const source = map?.getSource(sourceId) as VectorTileSource
  if (source && source.tiles) return source.tiles[0]
  else return ''
}
const setLayerVisibility = (layerId: string, visibility: boolean) => {
  map?.setLayoutProperty(layerId, 'visibility', visibility ? 'visible' : 'none')
}

const getPaintProperty = (layerId: string, name: string) => {
  if (hasLoaded.value) return map?.getPaintProperty(layerId, name)
}

defineExpose({
  getPaintProperty,
  update,
  setFilter,
  queryFeatures,
  queryRenderedFeatures,
  setPaintProperty,
  onZoom,
  changeSourceTilesUrl,
  setLayerVisibility,
  getSourceTilesUrl
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
  (filterIds) => {
    filterLayers(filterIds)
  },
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
  if (filterIds && map !== undefined && map.isStyleLoaded()) {
    map
      .getStyle()
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
  <v-container class="pa-0 position-relative fill-height" fluid>
    <div ref="container" class="map fill-height">
      <loading-circle :loading="loading" />
    </div>
    <legend-map v-if="legendColors" :colors="legendColors"></legend-map>
  </v-container>
</template>

<style scoped>
.map {
  height: 100%;
  width: 100%;
  position: relative;
}

.map:deep(.hovered-feature) {
  cursor: pointer !important;
}
</style>
