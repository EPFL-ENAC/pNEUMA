// To recalculate simply run the following query
// SELECT
//         MIN(timestamp) AS time_min,
//         MAX(timestamp) AS time_max
//     FROM
//         points;
export type DatasetMetadata = {
  tMin: number
  tMax: number
  dateStart: Date
}

const trajectories: Map<string, DatasetMetadata> = new Map([
  [
    '20181024_0830_0900',
    { tMin: 0, tMax: 787560, dateStart: new Date('2018-10-24T08:30:00.000Z') }
  ],
  [
    '20181024_0900_0930',
    { tMin: 0, tMax: 882320, dateStart: new Date('2018-10-24T09:00:00.000Z') }
  ],
  [
    '20181024_0930_1000',
    { tMin: 0, tMax: 830680, dateStart: new Date('2018-10-24T09:30:00.000Z') }
  ],
  [
    '20181024_1000_1030',
    { tMin: 0, tMax: 921200, dateStart: new Date('2018-10-24T10:00:00.000Z') }
  ],
  [
    '20181024_1030_1100',
    { tMin: 0, tMax: 450960, dateStart: new Date('2018-10-24T10:30:00.000Z') }
  ],
  [
    '20181029_0800_0830',
    { tMin: 0, tMax: 727960, dateStart: new Date('2018-10-29T08:00:00.000Z') }
  ],
  [
    '20181029_0830_0900',
    { tMin: 0, tMax: 768760, dateStart: new Date('2018-10-29T08:30:00.000Z') }
  ],
  [
    '20181029_0900_0930',
    { tMin: 0, tMax: 763560, dateStart: new Date('2018-10-29T09:00:00.000Z') }
  ],
  [
    '20181029_0930_1000',
    { tMin: 0, tMax: 990600, dateStart: new Date('2018-10-29T09:30:00.000Z') }
  ],
  [
    '20181029_1000_1030',
    { tMin: 0, tMax: 927241, dateStart: new Date('2018-10-29T10:00:00.000Z') }
  ],
  [
    '20181030_0800_0830',
    { tMin: 0, tMax: 835600, dateStart: new Date('2018-10-30T08:00:00.000Z') }
  ],
  [
    '20181030_0830_0900',
    { tMin: 0, tMax: 915160, dateStart: new Date('2018-10-30T08:30:00.000Z') }
  ],
  [
    '20181030_0900_0930',
    { tMin: 0, tMax: 950720, dateStart: new Date('2018-10-30T09:00:00.000Z') }
  ],
  [
    '20181030_0930_1000',
    { tMin: 0, tMax: 1044599, dateStart: new Date('2018-10-30T09:30:00.000Z') }
  ],
  [
    '20181030_1000_1030',
    { tMin: 0, tMax: 795880, dateStart: new Date('2018-10-30T10:00:00.000Z') }
  ],
  [
    '20181101_0800_0830',
    { tMin: 5213, tMax: 862319, dateStart: new Date('2018-11-01T08:00:00.000Z') }
  ],
  [
    '20181101_0830_0900',
    { tMin: 0, tMax: 908800, dateStart: new Date('2018-11-01T08:30:00.000Z') }
  ],
  [
    '20181101_0900_0930',
    { tMin: 0, tMax: 907080, dateStart: new Date('2018-11-01T09:00:00.000Z') }
  ],
  [
    '20181101_0930_1000',
    { tMin: 0, tMax: 890160, dateStart: new Date('2018-11-01T09:30:00.000Z') }
  ],
  ['20181101_1000_1030', { tMin: 0, tMax: 918760, dateStart: new Date('2018-11-01T08:00:00.000Z') }]
])

// See https://h3geo.org/docs/core-library/restable/ for reference
const hexArea = {
  '13': 43.87,
  '14': 6.267
}

// Time bin for hexmap in milliseconds (1 seconds)
const hexmapTimeBinMs = 10000

export default { trajectories, hexArea, hexmapTimeBinMs }
