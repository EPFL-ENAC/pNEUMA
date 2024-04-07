-- DROP FUNCTION public.speed_hexmap(int4, int4, int4, json);

CREATE OR REPLACE FUNCTION public.speed_hexmap(z integer, x integer, y integer, query_params json)
 RETURNS bytea
 LANGUAGE plpgsql
 IMMUTABLE PARALLEL SAFE STRICT
AS $function$
DECLARE
  mvt bytea;
BEGIN
  -- Generating the MVT with pre-existing Hexagonal Grid
  SELECT INTO mvt ST_AsMVT(tile, 'speed_hexmap', 4096, 'geom') FROM (
    SELECT
      ST_AsMVTGeom(
        h.geom, -- Existing hexagonal grid geometry
        ST_Transform(ST_TileEnvelope(z, x, y), 4326),
        4096, 64, true) AS geom,
        AVG(p.speed) AS avg_speed -- Calculate average speed for each hex
    FROM
      hexagons h
  	LEFT JOIN points p ON h.hex_id = p.hex_id
	WHERE h.geom &&	 ST_Transform(ST_TileEnvelope(z, x, y), 4326)
    group by h.geom
  ) as tile WHERE geom IS NOT NULL;

  RETURN mvt;
END
$function$
;
