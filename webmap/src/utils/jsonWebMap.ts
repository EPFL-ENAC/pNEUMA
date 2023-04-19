import type { LngLatLike } from 'maplibre-gl'
import type { SelectableItem } from './layerSelector'

export interface Parameters {
  center?: LngLatLike
  zoom?: number
  permanentLayerIds?: string[]
  popupLayerIds?: string[]
  selectableItems?: SelectableItem[]
}
