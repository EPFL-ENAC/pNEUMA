<script setup lang="ts">
import 'maplibre-gl/dist/maplibre-gl.css'

import {
  FullscreenControl,
  GeolocateControl,
  Map as Maplibre,
  NavigationControl,
  Popup,
  ScaleControl,
  VectorTileSource,
  type FilterSpecification,
  type LngLatLike,
  type StyleSetterOptions,
  type StyleSpecification
} from 'maplibre-gl'
import { onMounted, ref, watch } from 'vue'

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
let map: Maplibre | undefined = undefined

onMounted(() => {
  map = new Maplibre({
    container: 'maplibre-map',
    style: props.styleSpec,
    center: props.center,
    zoom: props.zoom,
    minZoom: props.minZoom,
    maxZoom: props.maxZoom
  })
  // map.showTileBoundaries = true
  map.addControl(new NavigationControl({}))
  map.addControl(new GeolocateControl({}))
  map.addControl(new ScaleControl({}))
  map.addControl(new FullscreenControl({}))

  // filterLayers(props.filterIds)

  let hoveredStateId: number = -1

  map.once('load', () => {
    // filterLayers(props.filterIds)
    if (!map) return

    map?.on('mouseleave', 'vehicles', () => {
      if (hoveredStateId) {
        map
          ?.setFeatureState(
            { source: 'pneuma', sourceLayer: 'trajectories', id: hoveredStateId },
            { hover: false }
          )
          .setFeatureState(
            { source: 'points', sourceLayer: 'points', id: hoveredStateId },
            { hover: false }
          )
      }
      hoveredStateId = -1
      if (map) map.getCanvas().classList.remove('hovered-feature')
    })

    map?.on('click', 'vehicles', function (e) {
      const source = map?.getSource('trajectories_points') as VectorTileSource
      // source.setTiles([
      //   `https://enacit4r-tiles.epfl.ch/get_trajectories_points/{z}/{x}/{y}?ids=${hoveredStateId}`
      // ])
      source.setTiles([
        `http://0.0.0.0:3000/get_trajectories_points/{z}/{x}/{y}?ids=${hoveredStateId}`
      ])
    })

    map?.on('mousemove', 'vehicles', function (e) {
      const features = e.features
      if (features && features.length > 0 && map) {
        map.getCanvas().classList.add('hovered-feature')
        throttle(
          () => {
            const newId = features[0]?.properties?.id || -1

            if (newId !== hoveredStateId) {
              if (hoveredStateId) {
                map
                  ?.setFeatureState(
                    { source: 'pneuma', sourceLayer: 'trajectories', id: hoveredStateId },
                    { hover: false }
                  )
                  .setFeatureState(
                    { source: 'points', sourceLayer: 'points', id: hoveredStateId },
                    { hover: false }
                  )
              }
              hoveredStateId = newId

              map
                ?.setFeatureState(
                  { source: 'pneuma', sourceLayer: 'trajectories', id: hoveredStateId },
                  { hover: true }
                )
                .setFeatureState(
                  { source: 'points', sourceLayer: 'points', id: hoveredStateId },
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
  throttle(() => map?.setFilter(layerId, filter, options), layerId, 100)
}

const setPaintProperty = (
  layerId: string,
  name: string,
  value: any,
  options?: StyleSetterOptions | undefined
) => {
  throttle(() => map?.setPaintProperty(layerId, name, value, options), layerId, 100)
}

const queryFeatures = (filter: any[]) => {
  return map?.querySourceFeatures('pneuma', {
    sourceLayer: 'trajectories',
    filter,
    validate: false
  })
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
  return map?.getPaintProperty(layerId, name)
}

defineExpose({
  getPaintProperty,
  update,
  setFilter,
  queryFeatures,
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
  <v-progress-linear v-if="loading" active color="primary" indeterminate />
  <v-responsive :aspect-ratio="aspectRatio" height="100%">
    <div id="maplibre-map" />
  </v-responsive>
</template>

<style scoped>
#maplibre-map {
  height: 100%;
}

#maplibre-map:deep(.hovered-feature) {
  cursor: pointer !important;
}
</style>
