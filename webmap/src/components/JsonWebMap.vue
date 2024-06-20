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
import type { DatasetMetadata } from '@/utils/metadata'

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

const dates = ['20181024', '20181029', '20181030', '20181101']
const dateItems = dates.map((dateStr) => {
  const year = Number(dateStr.substring(0, 4))
  const month = Number(dateStr.substring(4, 6))
  const day = Number(dateStr.substring(6, 8))
  const date = new Date(year, month - 1, day) // Month is 0-indexed in JS Date

  return {
    title: date.toLocaleDateString(), // Formats date in local format, adjust options as needed
    value: dateStr
  }
})

const selectedDate = ref<string>('20181101')
const selectedTimeRange = ref<string>('1000_1030')

const timeRanges = computed(() => {
  if (selectedDate.value == '20181024')
    return ['0830_0900', '0900_0930', '0930_1000', '1000_1030', '1030_1100']
  else return ['0800_0830', '0830_0900', '0900_0930', '0930_1000', '1000_1030']
})

watch(timeRanges, (newRanges) => {
  if (!newRanges.includes(selectedTimeRange.value)) selectedTimeRange.value = '1000_1030'
})

const timeRangeItems = computed(() => {
  return timeRanges.value.map((range) => {
    const start = range.split('_')[0]
    const end = range.split('_')[1]
    const formattedStart = `${start.substring(0, 2)}:${start.substring(2, 4)}`
    const formattedEnd = `${end.substring(0, 2)}:${end.substring(2, 4)}`

    return {
      title: `${formattedStart} - ${formattedEnd}`,
      value: range
    }
  })
})

watch([selectedDate, selectedTimeRange], () => {
  const date = selectedDate.value,
    time = selectedTimeRange.value
  const base = 'pmtiles://https://enacit4r-cdn.epfl.ch/pneuma'
  const url = `${base}/${date}_dX/${time}/`

  map.value?.changeSourceTilesUrl('hexmap', url + 'hexmap.pmtiles')
  map.value?.changeSourceTilesUrl('trajectories', url + 'trajectories.pmtiles')
})

const metadataSelected = computed<DatasetMetadata>(
  () =>
    (metadata.trajectories.get(selectedDate.value + '_' + selectedTimeRange.value) ||
      metadata.trajectories.get('20181101_1000_1030')) as DatasetMetadata
)

watch(metadataSelected, ({ tMin, tMax }) => {
  timeRange.value = [tMin, tMax]
})

const timeRange = ref<[number, number]>([metadataSelected.value.tMin, metadataSelected.value.tMax])

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
  <v-container class="fill-height pa-0 overflow-hidden" fluid>
    <v-row class="fill-height overflow-y-hidden">
      <v-col cols="2" md="2" class="pl-6 params-col border-e-md overflow-y-auto overflow-x-hidden">
        <v-card flat>
          <v-card-title>Dataset</v-card-title>
          <v-card-text>
            <v-select
              v-model="selectedDate"
              label="Date"
              :items="dateItems"
              variant="outlined"
              class="pt-1"
            ></v-select>
            <v-select
              v-model="selectedTimeRange"
              label="Time"
              :items="timeRangeItems"
              variant="outlined"
              class="pt-1"
              hide-details
            ></v-select>
          </v-card-text>
        </v-card>
        <v-card flat>
          <v-card-title> Trajectories </v-card-title>
          <v-card-text>
            <v-switch v-model="isHexmapSelected" hide-details label="Show aggregate"></v-switch>
            <v-radio-group v-if="isHexmapSelected" v-model="hexmapSelection" hide-details>
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
            <v-radio-group v-else v-model="trajectoriesSelection" hide-details density="default">
              <v-radio label="Speed" value="speed"></v-radio>
              <v-radio label="Density" :disabled="!isHexmapSelected" value="freq"></v-radio>
              <v-radio label="Acceleration" value="acceleration"></v-radio>
              <v-radio label="Vehicle type" value="vehicle_type"></v-radio>
            </v-radio-group>
          </v-card-text>
        </v-card>

        <v-card flat>
          <v-card-title> Vehicle category </v-card-title>
          <v-card-text>
            <v-checkbox
              v-for="(item, index) in vehicleTypes"
              :key="index"
              v-model="selectedTypes"
              density="compact"
              class="no-min-height"
              hide-details
              :label="item"
              :value="item"
            />
          </v-card-text>
        </v-card>
      </v-col>
      <v-col id="map-time-input-container" cols="10" md="10" class="py-0 pl-0 d-flex flex-column">
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

        <v-card flat class="mt-auto border-t-md pb-4 px-4">
          <v-card-title> Time </v-card-title>
          <v-card-text>
            <custom-range-slider
              v-model="timeRange"
              :min="metadataSelected.tMin"
              :max="metadataSelected.tMax"
              :step="metadata.hexmapTimeBinMs"
              :start-date="metadataSelected.dateStart"
            ></custom-range-slider>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<style scoped>
.v-slider-thumb__label span.thumb-label-nowrap {
  white-space: nowrap;
}

.params-col {
  max-height: 100vh;
}

.no-min-height {
  height: 32px;
}
</style>
