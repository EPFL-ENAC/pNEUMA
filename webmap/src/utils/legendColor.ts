export type LegendColor = {
  color: string
  label: string
}

const accelerationColors: LegendColor[] = [
  { label: '-0.75 m/s²', color: '#542788' },
  { label: '-0.3 m/s²', color: '#998ec3' },
  { label: '0 m/s²', color: '#d8daeb' },
  { label: '0.3 m/s²', color: '#fee0b6' },
  { label: '0.75 m/s²', color: '#f1a340' },
  { label: '1.25 m/s²', color: '#b35806' }
]

const speedColors: LegendColor[] = [
  { label: '0 km/h', color: '#a50026' },
  { label: '5 km/h', color: '#d73027' },
  { label: '15 km/h', color: '#f46d43' },
  { label: '25 km/h', color: '#fdae61' },
  { label: '35 km/h', color: '#fee08b' },
  { label: '45 km/h', color: '#d9ef8b' },
  { label: '55 km/h', color: '#a6d96a' },
  { label: '65 km/h', color: '#66bd63' },
  { label: '75 km/h', color: '#1a9850' },
  { label: '85 km/h', color: '#006837' }
]

const densityColors: LegendColor[] = [
  { label: '0 pt/m²', color: '#CCCCCC' },
  { label: '0.15 pt/m²', color: '#2b446e' },
  { label: '0.45 pt/m²', color: '#696970' },
  { label: '0.75 pt/m²', color: '#948f78' },
  { label: '1.05 pt/m²', color: '#caba6a' },
  { label: '1.35 pt/m²', color: '#fdea45' },
  { label: '1.75 pt/m²', color: '#fdea45' }
]
const vehicleTypeColors: LegendColor[] = [
  { label: 'Taxi', color: '#ffff33' },
  { label: 'Car', color: '#377eb8' },
  { label: 'Motorcycle', color: '#e41a1c' },
  { label: 'Medium Vehicle', color: '#a65628' },
  { label: 'Heavy Vehicle', color: '#8c564b' },
  { label: 'Bus', color: '#4daf4a' },
  { label: 'Other', color: '#CCCCCC' }
]

export { accelerationColors, speedColors, vehicleTypeColors, densityColors }
