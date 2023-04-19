export type SelectableItem = SelectableSingleItem | SelectableGroupItem
export interface SelectableParentItem {
  label: string
  selected?: boolean
}
export interface SelectableSingleItem extends SelectableParentItem {
  ids: string[]
  legend?: string
}
export interface SelectableGroupItem extends SelectableParentItem {
  children: SelectableSingleItem[]
}
