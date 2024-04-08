-- DROP FUNCTION public.speed_hexmap(int4, int4, int4, json);

CREATE OR REPLACE FUNCTION public.speed_hexmap(z integer, x integer, y integer, query_params json)
 RETURNS bytea
 LANGUAGE plpgsql
 IMMUTABLE PARALLEL SAFE STRICT
AS $function$
DECLARE
  mvt bytea;
  threshold_zoom_14 integer := 16; -- Set your threshold zoom level here
  threshold_zoom_15 integer := 18; -- Set your threshold zoom level here
BEGIN
  -- Generating the MVT with pre-existing Hexagonal Grid
  SELECT INTO mvt ST_AsMVT(tile, 'speed_hexmap', 4096, 'geom') FROM (
    SELECT
      ST_AsMVTGeom(
        h.geom, -- Existing hexagonal grid geometry
        ST_Transform(ST_TileEnvelope(z, x, y), 4326),
        4096, 64, true) AS geom,
       h.hex_id as h3index,
      avg_points.avg_speed as avg_speed, -- Average speed for each hex
      avg_points.avg_acceleration as avg_acceleration
    FROM
      hexagons h
    INNER JOIN (
    	SELECT
		    CASE
	         WHEN z < threshold_zoom_14 THEN hex_id_13
	         WHEN z >= threshold_zoom_14 AND z < threshold_zoom_15 THEN hex_id_14
	         ELSE hex_id_15 -- Assumed default resolution is 15
	        END AS hex_id,
	        AVG(speed) AS avg_speed, AVG(acceleration) as avg_acceleration
      	FROM points p
      	WHERE p.geom && ST_Transform(ST_TileEnvelope(z,x,y), 4326)
      	GROUP by
	      	CASE
  	         WHEN z < threshold_zoom_14 THEN hex_id_13
	         WHEN z >= threshold_zoom_14 AND z < threshold_zoom_15 THEN hex_id_14
	         ELSE hex_id_15 -- Assumed default resolution is 15
	        END
    ) AS avg_points ON h.hex_id = avg_points.hex_id
    WHERE h.geom && ST_Transform(ST_TileEnvelope(z, x, y), 4326)
  ) as tile WHERE geom IS NOT NULL;

  RETURN mvt;
END
$function$
;
