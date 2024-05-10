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

const isHexmapSelected = ref<boolean>(false)

watch(isHexmapSelected, (isHexmapSelected) => {
  if (isHexmapSelected && heatmapSelection.value == 'acceleration') heatmapSelection.value = 'speed'
  else if (!isHexmapSelected && heatmapSelection.value == 'freq') heatmapSelection.value = 'speed'
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

const colorByProgression = ref<boolean>(false)

const filterSingleVehicle = ref<boolean>(false)

const heatmapSelection = ref<string>('speed')
const timeRange = ref<[number, number]>([0, 20000])

const vehicleTypes = ['Taxi', 'Bus', 'Heavy Vehicle', 'Medium Vehicle', 'Motorcycle', 'Car']
const selectedTypes = ref<string[]>(vehicleTypes)

const legendItems = computed(() =>
  (parameters.value.selectableItems ?? [])
    .flatMap((item) => ('children' in item ? item.children : item))
    .filter((item) => item.ids.some((id) => filterIds.value.includes(id)))
    .flatMap((item) =>
      item.legend !== undefined
        ? [
            {
              label: item.label,
              legend: item.legend
            }
          ]
        : []
    )
)

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

watch([timeRange, heatmapSelection, isHexmapSelected, selectedTypes], () => {
  //For hexmap
  const category = heatmapSelection.value
  const propertyName = category + '_' + timeRange.value

  const currentFillColor = map.value?.getPaintProperty(category + '-heatmap', 'fill-color')

  if (currentFillColor && Array.isArray(currentFillColor) && currentFillColor.length > 3) {
    if (category == 'freq')
      currentFillColor[2] = createExpressionAverageFreq(
        timeRange.value[0],
        timeRange.value[1],
        10000
      )
    else
      currentFillColor[2] = createExpressionAverageSpeed(
        timeRange.value[0],
        timeRange.value[1],
        10000
      )

    map.value?.setPaintProperty(category + '-heatmap', 'fill-color', currentFillColor)
  }

  //For trajectories
  const currentLineColor = map.value?.getPaintProperty('trajectories', 'line-color')
  if (currentLineColor && Array.isArray(currentLineColor) && currentLineColor.length > 3) {
    currentLineColor[2] = ['to-number', ['get', category]]
    const newLineColor =
      category == 'acceleration'
        ? [
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
        : [
            'interpolate',
            ['linear'],
            ['to-number', ['get', 'speed']],
            -1,
            '#CCCCCC',
            0,
            '#440154',
            9,
            '#482878',
            18,
            '#3e4989',
            27,
            '#31688e',
            36,
            '#26828e',
            45,
            '#1f9e89',
            54,
            '#35b779',
            63,
            '#6ece58',
            72,
            '#b5de2b',
            80,
            '#fde725'
          ]

    map.value?.setPaintProperty('trajectories', 'line-color', newLineColor)
    map.value?.setFilter('trajectories', getFilter())
  }
})

const heatmapSourceUrl = computed(() => {
  // return `https://pneuma-dev.epfl.ch/tiles/speed_hexmap/{z}/{x}/{y}?vehicle_types=${JSON.stringify(
  return baseHeatmapSourceUrl.value + `?vehicle_types=${JSON.stringify(selectedTypes.value)}`
})
watch(heatmapSourceUrl, (newUrl, oldUrl) => {
  if (newUrl !== oldUrl) map.value?.changeSourceTilesUrl('heatmap', newUrl)
})

watch([heatmapSelection, isHexmapSelected], ([heatmapSelection, isHexmapSelected]) => {
  if (isHexmapSelected) {
    map.value?.setLayerVisibility('freq-heatmap', heatmapSelection === 'freq')
    map.value?.setLayerVisibility('speed-heatmap', heatmapSelection === 'speed')
    map.value?.setLayerVisibility('acceleration-heatmap', heatmapSelection === 'acceleration')
    map.value?.setLayerVisibility('trajectories', false)
  } else {
    map.value?.setLayerVisibility('freq-heatmap', false)
    map.value?.setLayerVisibility('speed-heatmap', false)
    map.value?.setLayerVisibility('acceleration-heatmap', false)
    map.value?.setLayerVisibility('trajectories', true)
  }
})
</script>

<template>
  <v-container class="fill-height pa-0" fluid>
    <v-row class="fill-height">
      <v-col cols="12" md="3" sm="6" class="pl-6">
        <v-card>
          <v-card-title> Map type selection </v-card-title>
          <v-card-text>
            <v-switch
              v-model="isHexmapSelected"
              hide-details
              :label="isHexmapSelected ? 'Hexagonal map' : 'Trajectories'"
            ></v-switch>
          </v-card-text>
        </v-card>
        <v-card>
          <v-card-title> Vehicle type </v-card-title>
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

        <v-card>
          <v-card-title> Time range in seconds </v-card-title>
          <v-card-text>
            <custom-range-slider
              v-model="timeRange"
              :min="0"
              :max="20 * 60 * 1000"
              :step="10 * 1000"
              density="compact"
              strict
              thumb-label
            ></custom-range-slider>
          </v-card-text>
        </v-card>
        <v-card>
          <v-card-title>Color encoding</v-card-title>
          <v-card-text>
            <v-radio-group v-model="heatmapSelection">
              <v-radio label="Density" value="freq" :disabled="!isHexmapSelected"></v-radio>
              <v-radio label="Speed" value="speed"></v-radio>
              <v-radio
                label="Acceleration"
                value="acceleration"
                :disabled="isHexmapSelected"
              ></v-radio>
            </v-radio-group>
          </v-card-text>
        </v-card>

        <v-divider class="border-opacity-100 mx-n3" />
      </v-col>
      <v-divider class="border-opacity-100" vertical />
      <v-col cols="12" md="9" sm="6" class="py-0 pl-0">
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
        />
      </v-col>
    </v-row>
  </v-container>
</template>

<style>
.v-slider-thumb__label span.thumb-label-nowrap {
  white-space: nowrap;
}
</style>
