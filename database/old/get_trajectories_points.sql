-- DROP FUNCTION public.get_trajectories_points(int4, int4, int4, json);

CREATE OR REPLACE FUNCTION public.get_trajectories_points(z integer, x integer, y integer, query_params json)
 RETURNS bytea
 LANGUAGE plpgsql
 IMMUTABLE PARALLEL SAFE STRICT
AS $function$
DECLARE
  mvt bytea;
  ids_array integer[];
BEGIN
  -- Convert the comma-separated string to an array
  ids_array := string_to_array(query_params->>'ids', ',')::integer[];

  SELECT INTO mvt ST_AsMVT(tile, 'get_trajectories_points', 4096, 'geom') FROM (
    SELECT
      ST_AsMVTGeom(
          ST_Transform(ST_CurveToLine(geom), 3857),
          ST_TileEnvelope(z, x, y),
          4096, 64, true) AS geom,
          speed	
    FROM points
    WHERE geom && ST_Transform(ST_TileEnvelope(z, x, y), 4326)
    AND id = ANY(ids_array)
  ) as tile WHERE geom IS NOT NULL;

  RETURN mvt;
END
$function$
;
