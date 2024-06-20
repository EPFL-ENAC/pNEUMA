--EXPLAIN (ANALYZE, VERBOSE) SELECT public.speed_hexmap(18,148353,101124, '{}');
--explain (analyse, verbose) SELECT id, vehicle_type, lat, lon, speed, timestamp, geom, lat_acc, lon_acc
--FROM points
--WHERE timestamp BETWEEN 41 AND 43;


--explain (analyse, verbose) SELECT
--  id,
--  vehicle_type,
--  lat,
--  lon,
--  speed,
--  timestamp,
--  geom,
--  lat_acc,
--  lon_acc
--FROM
--  points
--WHERE
--  ST_Intersects(
--    geom,
--    ST_Transform(ST_TileEnvelope(18,148353,101125), 4326) -- Adjust the SRID (4326) to match your geom column
--  );

EXPLAIN (ANALYZE, VERBOSE) SELECT * FROM public.speed_hexmap(18,148353,101125,'{}');

SELECT 
  ST_AsText(ST_TileEnvelope(17,74176,50564)) as tile_envelope,
  COUNT(*) as hexagon_count
FROM hexagons h
WHERE ST_Intersects(ST_TileEnvelope(17,74176,50564), ST_Transform(h.geom, 3857))
GROUP BY ST_TileEnvelope(17,74176,50564);


SELECT COUNT(*)
FROM hexagons h
WHERE h.geom && ST_Transform(ST_TileEnvelope(17, 74176, 50564), 4326);


explain ANALYZE
SELECT public.speed_hexmap(17, 74176, 50564, '{}') as mvt;

CREATE INDEX ON hexagons (hex_id);



