CREATE TABLE hexagons (
  hex_id serial PRIMARY KEY,
  geom geometry(Polygon, 4326) -- or the appropriate SRID
)
;


INSERT INTO hexagons (geom)
SELECT ST_Transform(hex.geom, 4326)
FROM (
    SELECT (ST_HexagonGrid(
        2, -- Edge length of each hexagon in meters
        ST_Transform(ST_SetSRID(ST_EstimatedExtent('points', 'geom'), 4326), 3857)
    )).geom AS geom
) AS hex
LEFT JOIN points p ON ST_Contains(ST_Transform(hex.geom, 4326), p.geom)
GROUP BY hex.geom
HAVING COUNT(p.geom) > 0;

