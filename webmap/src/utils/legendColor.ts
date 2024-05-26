export type LegendColor = {
  color: string
  label: string
}

const accelerationColors: LegendColor[] = [
  { label: '< -0.5 m/s²', color: '#542788' },
  { label: '-0.5 to -0.1 m/s²', color: '#998ec3' },
  { label: '-0.1 to 0.1 m/s²', color: '#d8daeb' },
  { label: '0.1 to 0.5 m/s²', color: '#fee0b6' },
  { label: '0.5 to 1 m/s²', color: '#f1a340' },
  { label: '> 1 m/s²', color: '#b35806' }
]
const speedColors: LegendColor[] = [
  { label: '< 0 km/h', color: '#CCCCCC' },
  { label: '0 to 9 km/h', color: '#440154' },
  { label: '9 to 18 km/h', color: '#482878' },
  { label: '18 to 27 km/h', color: '#3e4989' },
  { label: '27 to 36 km/h', color: '#31688e' },
  { label: '36 to 45 km/h', color: '#26828e' },
  { label: '45 to 54 km/h', color: '#1f9e89' },
  { label: '54 to 63 km/h', color: '#35b779' },
  { label: '63 to 72 km/h', color: '#6ece58' },
  { label: '72 to 80 km/h', color: '#b5de2b' },
  { label: '> 80 km/h', color: '#fde725' }
]
const progressionColors: LegendColor[] = [
  { label: '0% to 10%', color: '#440154' },
  { label: '10% to 20%', color: '#482878' },
  { label: '20% to 30%', color: '#3e4989' },
  { label: '30% to 40%', color: '#31688e' },
  { label: '40% to 50%', color: '#26828e' },
  { label: '50% to 60%', color: '#1f9e89' },
  { label: '60% to 70%', color: '#35b779' },
  { label: '70% to 80%', color: '#6ece58' },
  { label: '80% to 90%', color: '#b5de2b' },
  { label: '90% to 100%', color: '#fde725' }
]
const vehicleTypeColors: LegendColor[] = [
  { label: 'Taxi', color: '#1f77b4' },
  { label: 'Car', color: '#ff7f0e' },
  { label: 'Motorcycle', color: '#2ca02c' },
  { label: 'Medium Vehicle', color: '#d62728' },
  { label: 'Heavy Vehicle', color: '#9467bd' },
  { label: 'Bus', color: '#8c564b' },
  { label: 'Other', color: '#CCCCCC' }
]

const densityColors: LegendColor[] = [
  { label: '< 0', color: '#CCCCCC' },
  { label: '0', color: '#002051' },
  { label: '0 to 0.3', color: '#2b446e' },
  { label: '0.3 to 0.6', color: '#696970' },
  { label: '0.6 to 0.9', color: '#948f78' },
  { label: '0.9 to 1.2', color: '#caba6a' },
  { label: '1.2 to 1.5', color: '#fdea45' },
  { label: '> 1.5', color: '#fdea45' }
]
export { accelerationColors, speedColors, progressionColors, vehicleTypeColors, densityColors }
