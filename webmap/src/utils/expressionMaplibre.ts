const createExpressionAverageSpeed = (tMin: number, tMax: number, step: number) => {
  const i0 = Math.floor(tMin / step),
    i1 = Math.floor(tMax / step)
  const indexes = Array.from({ length: i1 - i0 + 1 }, (_, i) => i + i0)

  const speedSumExpressions = indexes.map((i) => [
    '*',
    ['to-number', ['coalesce', ['get', `speed_${i}`], 0]],
    ['to-number', ['coalesce', ['get', `freq_${i}`], 0]]
  ])
  const freqSumExpressions = indexes.map((i) => [
    'to-number',
    ['coalesce', ['get', `freq_${i}`], 0]
  ])

  // Use the '+' operator to sum up all expressions for property values and frequencies
  const summedSpeedExpression = ['coalesce', ['+', ...speedSumExpressions, -1], -1] as (
    | string
    | string[]
  )[]

  const summedFrequenciesExpression = ['coalesce', ['+', ...freqSumExpressions, 1], 1] as (
    | string
    | string[]
  )[]

  return ['/', summedSpeedExpression, summedFrequenciesExpression]
}

const createExpressionAverageFreq = (tMin: number, tMax: number, step: number) => {
  console.log('createExpressionAverageFreq', tMin, tMax, step)
  const i0 = Math.floor(tMin / step),
    i1 = Math.floor(tMax / step)
  const indexes = Array.from({ length: i1 - i0 + 1 }, (_, i) => i + i0)
  const freqSumExpressions = indexes.map((i) => [
    'to-number',
    ['coalesce', ['get', `freq_${i}`], 0]
  ])
  console.log(freqSumExpressions)

  const summedFrequenciesExpression = ['coalesce', ['+', ...freqSumExpressions, 1], 1] as (
    | string
    | string[]
  )[]

  // Create expressions to check for the existence of each freq_idx using 'has'
  const validCountExpressions = indexes.map((i) => ['to-number', ['has', `freq_${i}`]])

  // Sum the validCountExpressions to get the count of existing frequencies
  const validCountExpression = ['+', ...validCountExpressions]

  return ['/', summedFrequenciesExpression, ['max', ['coalesce', validCountExpression, 1], 1]]
}

export { createExpressionAverageSpeed, createExpressionAverageFreq }
