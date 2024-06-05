<script setup lang="ts">
import CustomRangeSlider from '@/components/CustomRangeSlider.vue'
import MapLibreMap from '@/components/MapLibreMap.vue'

import type { Parameters } from '@/utils/jsonWebMap'
import type { SelectableSingleItem } from '@/utils/layerSelector'
import axios from 'axios'
import type { ExpressionSpecification } from 'maplibre-gl'
import { computed, ref, shallowRef, triggerRef, watch } from 'vue'
import {
  createExpressionAverageSpeed,
  createExpressionAverageFreq
} from '@/utils/expressionMaplibre'
import {
  accelerationColors,
  speedColors,
  vehicleTypeColors,
  densityColors
} from '@/utils/legendColor'

import metadata from '@/utils/metadata'

const isHexmapSelected = ref<boolean>(false)

const legendColors = computed(() => {
  if (isHexmapSelected.value) {
    switch (hexmapSelection.value) {
      case 'speed':
        return speedColors
      case 'freq':
        return densityColors
    }
  } else {
    switch (trajectoriesSelection.value) {
      case 'speed':
        return speedColors
      case 'acceleration':
        return accelerationColors
      case 'vehicle_type':
        return vehicleTypeColors
    }
  }
  return []
})

const props = defineProps<{
  styleUrl: string
  parametersUrl: string
}>()

const map = ref<InstanceType<typeof MapLibreMap>>()

const parameters = shallowRef<Parameters>({})
const selectedLayerIds = ref<string[]>([
  ...(parameters.value?.selectableItems?.flatMap((selectableItem) => {
    if (selectableItem.selected && 'ids' in selectableItem) {
      const selectableSingleItem = selectableItem as SelectableSingleItem
      return selectableSingleItem.ids
    }
    return []
  }) ?? [])
])

const filterIds = computed<string[]>(() => [
  ...(parameters.value.permanentLayerIds ?? []),
  ...selectedLayerIds.value,
  ...(filterSingleVehicle.value ? ['ghost'] : [])
])

const filterSingleVehicle = ref<boolean>(false)

const hexmapSelection = ref<string>('speed')
const trajectoriesSelection = ref<string>('speed')

const timeRange = ref<[number, number]>([
  metadata.trajectories['20181024_0830_0900'].tMin,
  metadata.trajectories['20181024_0830_0900'].tMax
])

const vehicleTypes = ['Car', 'Taxi', 'Bus', 'Motorcycle', 'Medium Vehicle', 'Heavy Vehicle']
const toVehicleTypeShort = (vehicleType: string) => {
  switch (vehicleType) {
    case 'Taxi':
      return 'T'
    case 'Bus':
      return 'B'
    case 'Heavy Vehicle':
      return 'HV'
    case 'Medium Vehicle':
      return 'MV'
    case 'Motorcycle':
      return 'M'
    case 'Car':
      return 'C'
    default:
      return vehicleType
  }
}
const selectedTypes = ref<string[]>(vehicleTypes)

watch(
  () => props.parametersUrl,
  (parametersUrl) => {
    axios
      .get<Parameters>(parametersUrl)
      .then((response) => response.data)
      .then((data) => {
        parameters.value = data
        triggerRef(parameters)
        map.value?.update(data.center, data.zoom)
      })
  },
  { immediate: true }
)

const getRangeFilter = (
  name: string,
  range: [number, number] | number[]
): ExpressionSpecification[] => [
  ['>=', ['get', name], range[0]],
  ['<=', ['get', name], range[1]]
]

const getTypeFilter = (): ExpressionSpecification => {
  return [
    'in',
    ['get', 'vehicle_type'],
    ['literal', selectedTypes.value as ExpressionSpecification]
  ]
}

const getFilter = (): ExpressionSpecification => {
  const t0 = timeRange.value[0]
  const t1 = timeRange.value[1] // 10 seconds time window

  let filter: ExpressionSpecification = ['all', getTypeFilter()]

  filter = filter.concat([
    ...getRangeFilter('t0', [t0, t1]),
    ...getRangeFilter('t1', [t0, t1])
  ]) as ExpressionSpecification

  return filter
}

const baseHeatmapSourceUrl = ref<string>('')
const callbackMapLoaded = () => {
  baseHeatmapSourceUrl.value = map.value?.getSourceTilesUrl('heatmap') ?? ''
}

const setPaintTrajectories = (selection: string) => {
  const currentLineColor = map.value?.getPaintProperty('trajectories', 'line-color')

  if (currentLineColor && Array.isArray(currentLineColor) && currentLineColor.length > 3) {
    let newLineColor = []
    switch (selection) {
      case 'acceleration':
        newLineColor = [
          'interpolate',
          ['linear'],
          ['to-number', ['get', 'acceleration']],
          -1,
          '#542788',
          -0.5,
          '#998ec3',
          -0.1,
          '#d8daeb',
          0.1,
          '#fee0b6',
          0.5,
          '#f1a340',
          1,
          '#b35806'
        ]
        break
      case 'speed':
        newLineColor = [
          'interpolate',
          ['linear'],
          ['to-number', ['get', 'speed']],
          -1,
          '#CCCCCC',
          0,
          '#a50026',
          5,
          '#d73027',
          15,
          '#f46d43',
          25,
          '#fdae61',
          35,
          '#fee08b',
          45,
          '#d9ef8b',
          55,
          '#a6d96a',
          65,
          '#66bd63',
          75,
          '#1a9850',
          85,
          '#006837'
        ]
        break

      case 'vehicle_type':
        newLineColor = [
          'match',
          ['get', 'vehicle_type'],
          'Taxi',
          '#ffff33',
          'Car',
          '#377eb8',
          'Motorcycle',
          '#e41a1c',
          'Medium Vehicle',
          '#a65628',
          'Heavy Vehicle',
          '#8c564b',
          'Bus',
          '#4daf4a',
          '#CCCCCC'
        ]
        break
      default:
        newLineColor = currentLineColor
    }
    map.value?.setPaintProperty('trajectories', 'line-color', newLineColor)
  }
}

const setPaintHexmap = (selection: string) => {
  const currentFillColor = map.value?.getPaintProperty(selection + '-heatmap', 'fill-color')

  if (currentFillColor && Array.isArray(currentFillColor) && currentFillColor.length > 3) {
    if (selection == 'freq')
      currentFillColor[2] = createExpressionAverageFreq(
        timeRange.value[0],
        timeRange.value[1],
        10000,
        selectedTypes.value.map(toVehicleTypeShort)
      )
    else
      currentFillColor[2] = createExpressionAverageSpeed(
        timeRange.value[0],
        timeRange.value[1],
        10000,
        selectedTypes.value.map(toVehicleTypeShort)
      )

    map.value?.setPaintProperty(selection + '-heatmap', 'fill-color', currentFillColor)
  }
}

watch([timeRange, hexmapSelection, trajectoriesSelection, isHexmapSelected, selectedTypes], () => {
  //For hexmap
  const category = hexmapSelection.value

  if (isHexmapSelected.value) setPaintHexmap(category)
  else {
    map.value?.setFilter('trajectories', getFilter())
    setPaintTrajectories(trajectoriesSelection.value)
  }
})

watch([hexmapSelection, isHexmapSelected], ([hexmapSelection, isHexmapSelected]) => {
  if (isHexmapSelected) {
    map.value?.setLayerVisibility('freq-heatmap', hexmapSelection === 'freq')
    map.value?.setLayerVisibility('speed-heatmap', hexmapSelection === 'speed')
    map.value?.setLayerVisibility('trajectories', false)
  } else {
    map.value?.setLayerVisibility('freq-heatmap', false)
    map.value?.setLayerVisibility('speed-heatmap', false)
    map.value?.setLayerVisibility('trajectories', true)
  }
})
</script>

<template>
  <v-container class="fill-height pa-0" fluid>
    <v-row class="fill-height">
      <v-col cols="12" md="2" sm="6" class="pl-6">
        <v-card flat>
          <v-card-title> Trajectories </v-card-title>
          <v-card-text>
            <v-switch v-model="isHexmapSelected" hide-details label="Show aggregate"></v-switch>
            <v-radio-group v-if="isHexmapSelected" v-model="hexmapSelection">
              <v-radio label="Speed" value="speed"></v-radio>
              <v-radio label="Density" :disabled="!isHexmapSelected" value="freq"></v-radio>
              <v-radio
                label="Acceleration"
                :disabled="isHexmapSelected"
                value="acceleration"
              ></v-radio>
              <v-radio
                label="Vehicle type"
                :disabled="isHexmapSelected"
                value="vehicle_type"
              ></v-radio>
            </v-radio-group>
            <v-radio-group v-else v-model="trajectoriesSelection">
              <v-radio label="Speed" value="speed"></v-radio>
              <v-radio label="Density" :disabled="!isHexmapSelected" value="freq"></v-radio>
              <v-radio label="Acceleration" value="acceleration"></v-radio>
              <v-radio label="Vehicle type" value="vehicle_type"></v-radio>
            </v-radio-group>
          </v-card-text>
        </v-card>
        <v-divider />

        <v-card flat>
          <v-card-title> Vehicle category </v-card-title>
          <v-card-text>
            <v-checkbox
              v-for="(item, index) in vehicleTypes"
              :key="index"
              v-model="selectedTypes"
              density="compact"
              hide-details
              :label="item"
              :value="item"
            />
          </v-card-text>
        </v-card>
        <v-divider />
      </v-col>
      <v-divider class="border-opacity-100" vertical />
      <v-col
        id="map-time-input-container"
        cols="12"
        md="10"
        sm="6"
        class="py-0 pl-0 d-flex flex-column"
      >
        <MapLibreMap
          ref="map"
          :center="parameters.center"
          :style-spec="styleUrl"
          :filter-ids="filterIds"
          :popup-layer-ids="parameters.popupLayerIds"
          :zoom="parameters.zoom"
          :max-zoom="20"
          :min-zoom="14"
          :callback-loaded="callbackMapLoaded"
          class="flex-grow-1"
          :legend-colors="legendColors"
          :continuous-color="!(!isHexmapSelected && trajectoriesSelection == 'vehicle_type')"
        />
        <v-divider class="border-opacity-100" />

        <v-card flat class="mt-auto pb-4 px-4">
          <v-card-title> Time </v-card-title>
          <v-card-text>
            <custom-range-slider
              v-model="timeRange"
              :min="metadata.trajectories['20181024_0830_0900'].tMin"
              :max="metadata.trajectories['20181024_0830_0900'].tMax"
              :step="metadata.hexmapTimeBinMs"
              :start-date="metadata.trajectories['20181024_0830_0900'].dateStart"
            ></custom-range-slider>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<style>
.v-slider-thumb__label span.thumb-label-nowrap {
  white-space: nowrap;
}
</style>
