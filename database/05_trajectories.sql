-- DROP FUNCTION public.trajectories(int4, int4, int4, json);

CREATE OR REPLACE FUNCTION public.trajectories(z integer, x integer, y integer, query_params json)
 RETURNS bytea
 LANGUAGE plpgsql
 IMMUTABLE PARALLEL SAFE STRICT
AS $function$
DECLARE
  mvt bytea;

tile_geom geometry;

res_zoom float4;

BEGIN


    tile_geom := st_transform(st_tileenvelope(z,
x,
y),
4326);
-- Determine group size based on zoom level
  
    IF z <= 14 THEN
    	res_zoom := 6;

ELSIF z = 15 THEN
        res_zoom := 3;

ELSIF z <= 17 THEN
    res_zoom := 1.5;

ELSIF z = 18 THEN
   		res_zoom := 0.5;

ELSEIF z > 18 THEN
        res_zoom := 0.1;
-- Smaller groups for higher detail
END IF;
-- Execute query
    SELECT
	INTO
	mvt st_asmvt(tile,
	'trajectories',
	4096,
	'geom')
FROM
	(
	SELECT
		st_asmvtgeom(
            geom,
		tile_geom,
		4096,
		64,
		TRUE
          ) AS geom,
		speed,
		acceleration,
		t0,
		t1,
		vehicle_type,
		vehicle_id,
		progression
	FROM
		segments s
	WHERE
		s.res = res_zoom
		AND s.geom && tile_geom 
    ) AS tile;

RETURN mvt;
END;

$function$
;
