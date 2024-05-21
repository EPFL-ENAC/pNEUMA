-- DROP FUNCTION public.speed_hexmap(int4, int4, int4, json);

CREATE OR REPLACE
FUNCTION public.speed_hexmap(z integer,
x integer,
y integer,
query_params JSON)
 RETURNS bytea
 LANGUAGE plpgsql
 IMMUTABLE PARALLEL SAFE STRICT
AS $function$
DECLARE
  mvt bytea;

threshold_zoom integer := 17;
-- set your threshold zoom level here
tile_margin NUMERIC;
-- set your threshold zoom level here
hex_area NUMERIC;
-- variable to store hexagon area


margin_tile_geom geometry;

tile_geom geometry;

time_bin_size_ms integer := 1000 * 10;
-- time bin SIZE IS 10 s * 1000 FOR ms
BEGIN
	

IF z < threshold_zoom THEN
		hex_area := 43.870;
-- example area value for resolution 13
tile_margin := 8;
ELSE
		hex_area := 6.267;
-- example area value for resolution level 14
tile_margin := 6;
END IF;

tile_geom := st_transform(st_tileenvelope(z,
x,
y),
4326);

margin_tile_geom := st_transform(st_envelope(st_buffer(st_tileenvelope(z,
x,
y),
tile_margin)),
4326);

WITH time_bounds AS (
SELECT
	min(timestamp) AS time_min,
	max(timestamp) AS time_max
FROM
	points
),
time_bins AS (
SELECT
	generate_series(time_bounds.time_min::integer,
	time_bounds.time_max::integer,
	time_bin_size_ms::integer) AS time_bin
FROM
	time_bounds
)
-- Generate the MVT with pre-existing hexagonal grid
SELECT
    INTO mvt st_asmvt(tile, 'speed_hexmap', 4096, 'geom')
FROM (
    SELECT
        st_asmvtgeom(geom, tile_geom, 4096, 64, TRUE) AS geom,
        hex_id,
        hex_area AS area,
        jsonb_object_agg(concat('freq_', vehicle_type	, '_', (time_bin/ time_bin_size_ms)::SMALLINT), freq) AS frequencies,
        jsonb_object_agg(concat('speed_', vehicle_type	, '_', (time_bin/ time_bin_size_ms)::SMALLINT), avg_speed) AS speeds
    FROM (
        SELECT
            hex_id,
            geom,
            vehicle_type,
            time_bin,
            COALESCE(avg(speed)::SMALLINT, 0) AS avg_speed,
            count(*) AS freq
        FROM (
            SELECT
                hexs.hex_id AS hex_id,
                hexs.geom AS geom,
                hexs.time_bin AS time_bin,
                p.vehicle_type,
                p.speed
            FROM (
                SELECT
                    hex_id,
                    time_bin,
                    geom
                FROM
                    hexagons
                CROSS JOIN time_bins
                WHERE
                    geom && margin_tile_geom
                    AND (CASE
                        WHEN z < threshold_zoom THEN res = 13
                        ELSE res = 14
                    END)
            ) AS hexs
            JOIN points p ON
                ((CASE 
                    WHEN z < threshold_zoom THEN hexs.hex_id = p.hex_id_13
                    ELSE hexs.hex_id = p.hex_id_14
                END) AND p.timestamp BETWEEN time_bin AND time_bin + time_bin_size_ms)
        ) AS subquery
        GROUP BY
            hex_id, geom, vehicle_type, time_bin
    ) AS aggregated_data
    GROUP BY
        hex_id, geom, hex_area
) AS tile
WHERE
    geom IS NOT NULL;

RETURN mvt;

END
$function$
;
