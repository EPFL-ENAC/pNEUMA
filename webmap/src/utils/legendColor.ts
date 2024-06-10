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
  { label: '0 datapoints/m²', color: '#000004' },
  { label: '2.2 datapoints/m²', color: '#1b0c41' },
  { label: '4.4 datapoints/m²', color: '#4a0c6b' },
  { label: '6.6 datapoints/m²', color: '#781c6d' },
  { label: '8.8 datapoints/m²', color: '#a52c60' },
  { label: '11 datapoints/m²', color: '#cf4446' },
  { label: '13.2 datapoints/m²', color: '#ed6925' },
  { label: '15.4 datapoints/m²', color: '#fb9b06' },
  { label: '17.6 datapoints/m²', color: '#f7d13d' },
  { label: '20 datapoints/m²', color: '#fcffa4' }
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
