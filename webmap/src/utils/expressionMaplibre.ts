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
  const i0 = Math.floor(tMin / step),
    i1 = Math.floor(tMax / step)
  const indexes = Array.from({ length: i1 - i0 + 1 }, (_, i) => i + i0)

  const freqSumExpressions = indexes.map((i) => [
    'to-number',
    ['coalesce', ['get', `freq_${i}`], 0]
  ])

  const summedFrequenciesExpression = ['coalesce', ['+', ...freqSumExpressions, 1], 1] as (
    | string
    | string[]
  )[]

  return ['/', summedFrequenciesExpression, indexes.length]
}

export { createExpressionAverageSpeed, createExpressionAverageFreq }
