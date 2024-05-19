// To recalculate simply run the following query
// SELECT
//         MIN(timestamp) AS time_min,
//         MAX(timestamp) AS time_max
//     FROM
//         points;

const trajectories = {
  '20181024_0830_0900': {
    tMin: 0,
    tMax: 787560,
    dateStart: new Date('2018-10-24 08:30:00')
  }
}

// See https://h3geo.org/docs/core-library/restable/ for reference
const hexArea = {
  '13': 43.87,
  '14': 6.267
}

// Time bin for hexmap in milliseconds (10 seconds)
const hexmapTimeBinMs = 10000

export default { trajectories, hexArea, hexmapTimeBinMs }
