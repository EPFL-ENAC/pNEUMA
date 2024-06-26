const createExpressionAverageSpeed = (
  tMin: number,
  tMax: number,
  step: number,
  vehicle_types: string[]
) => {
  const i0 = Math.floor(tMin / step),
    i1 = Math.floor(tMax / step)
  const indexes = Array.from({ length: i1 - i0 + 1 }, (_, i) => i + i0)

  const speedSumExpressions = indexes.flatMap((i) =>
    vehicle_types.map((type: string) => [
      '*',
      ['to-number', ['get', `speed_${type}_${i}`]],
      ['to-number', ['get', `freq_${type}_${i}`]]
    ])
  )
  const freqSumExpressions = indexes.flatMap((i) =>
    vehicle_types.map((type: string) => ['to-number', ['get', `freq_${type}_${i}`]])
  )

  // Use the '+' operator to sum up all expressions for property values and frequencies
  const summedSpeedExpression = ['coalesce', ['+', ...speedSumExpressions, -1], -1] as (
    | string
    | string[]
  )[]

  const summedFrequenciesExpression = ['coalesce', ['+', ...freqSumExpressions], 1] as (
    | string
    | string[]
  )[]

  return ['/', summedSpeedExpression, summedFrequenciesExpression]
}

const createExpressionAverageFreq = (
  tMin: number,
  tMax: number,
  step: number,
  vehicle_types: string[]
) => {
  const i0 = Math.floor(tMin / step),
    i1 = Math.floor(tMax / step)
  const indexes = Array.from({ length: i1 - i0 + 1 }, (_, i) => i + i0)
  const freqSumExpressions = indexes.flatMap((i) =>
    vehicle_types.map((type: string) => ['to-number', ['get', `freq_${type}_${i}`]])
  )

  const dividerExpression = ['sqrt', ['to-number', ['get', 'area']]]
  const summedFrequenciesExpression = [
    '/',
    ['coalesce', ['+', ...freqSumExpressions], 0],
    dividerExpression
  ] as (string | string[])[]

  // Create expressions to check for the existence of each freq_idx using 'has'
  const validCountExpressions = indexes.flatMap((i) =>
    vehicle_types.map((type: string) => ['to-number', ['has', `freq_${type}_${i}`]])
  )

  // Sum the validCountExpressions to get the count of existing frequencies
  const validCountExpression = ['+', ...validCountExpressions]

  return ['/', summedFrequenciesExpression, ['max', ['coalesce', validCountExpression, 1], 1]]
}

export { createExpressionAverageSpeed, createExpressionAverageFreq }
