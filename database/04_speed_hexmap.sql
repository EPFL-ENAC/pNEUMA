-- DROP FUNCTION public.speed_hexmap(int4, int4, int4, json);

CREATE OR REPLACE FUNCTION public.speed_hexmap(z integer, x integer, y integer, query_params json)
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
vehicle_types vehicle_type_enum[];
-- array to store vehicle types from query parameters
start_time NUMERIC;

end_time NUMERIC;

margin_tile_geom geometry;

tile_geom geometry;

BEGIN
	

	
	IF query_params->>'start_time' IS NOT NULL THEN
	    start_time := (query_params->>'start_time')::float;
ELSE
	    start_time := NULL;
-- or some default value
END IF;

IF query_params->>'end_time' IS NOT NULL THEN
	    end_time := (query_params->>'end_time')::float;
ELSE
	    end_time := NULL;
-- or some default value
END IF;

IF query_params->'vehicle_types' IS NOT NULL THEN
	    vehicle_types := ARRAY(
SELECT
	json_array_elements_text(query_params->'vehicle_types')::vehicle_type_enum);
ELSE
	    vehicle_types := '{}';
-- assign an empty array if 'vehicle_types' is not in query_params
END IF;
-- check if vehicle_types array is empty and set it to null if it is
	IF vehicle_types = '{}' THEN
	    vehicle_types := NULL;
END IF;

IF z < threshold_zoom THEN
		hex_area := 43.870;
-- example area value for resolution 13
tile_margin := 8;
ELSE
		hex_area := 6.267;
-- example area value for resolution level 14
tile_margin := 3;
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
	min(MINUTE) AS time_min,
	max(MINUTE) AS time_max
FROM
	points
),
minute_bins AS (
SELECT
	generate_series(time_bounds.time_min::integer,
	time_bounds.time_max::integer) AS minute_bin
FROM
	time_bounds
)

-- generating the mvt with pre-existing hexagonal grid
  SELECT
	INTO
	mvt st_asmvt(tile,
	'speed_hexmap',
	4096,
	'geom')
FROM
	(
	SELECT
		st_asmvtgeom(
        avg_points.geom,
		-- existing hexagonal grid geometry
		tile_geom,
		4096,
		64,
		TRUE) AS geom,
		avg_points.hex_id AS h3index,
		hex_area AS area,
        avg_speeds[1] AS speed_1,
		avg_speeds[2] AS speed_2,
		avg_speeds[3] AS speed_3,
		avg_speeds[4] AS speed_4,
		avg_speeds[5] AS speed_5,
		avg_speeds[6] AS speed_6,
		avg_speeds[7] AS speed_7,
		avg_speeds[8] AS speed_8,
		avg_speeds[9] AS speed_9,
		avg_speeds[10] AS speed_10,
		avg_speeds[11] AS speed_11,
		avg_speeds[12] AS speed_12,
		avg_speeds[13] AS speed_13,
		avg_speeds[14] AS speed_14,
		avg_speeds[15] AS speed_15,
		avg_speeds[16] AS speed_16,
		avg_speeds[17] AS speed_17,
		avg_speeds[18] AS speed_18,
		avg_speeds[19] AS speed_19,
		avg_speeds[20] AS speed_20,
		avg_speeds[21] AS speed_21,
		avg_speeds[22] AS speed_22,
		avg_speeds[23] AS speed_23,
		avg_speeds[24] AS speed_24,
		avg_speeds[25] AS speed_25,
		avg_speeds[26] AS speed_26,
		avg_speeds[27] AS speed_27,
		avg_speeds[28] AS speed_28,
		avg_speeds[29] AS speed_29,
        avg_accelerations[1] AS acceleration_1,
		avg_accelerations[2] AS acceleration_2,
		avg_accelerations[3] AS acceleration_3,
		avg_accelerations[4] AS acceleration_4,
		avg_accelerations[5] AS acceleration_5,
		avg_accelerations[6] AS acceleration_6,
		avg_accelerations[7] AS acceleration_7,
		avg_accelerations[8] AS acceleration_8,
		avg_accelerations[9] AS acceleration_9,
		avg_accelerations[10] AS acceleration_10,
		avg_accelerations[11] AS acceleration_11,
		avg_accelerations[12] AS acceleration_12,
		avg_accelerations[13] AS acceleration_13,
		avg_accelerations[14] AS acceleration_14,
		avg_accelerations[15] AS acceleration_15,
		avg_accelerations[16] AS acceleration_16,
		avg_accelerations[17] AS acceleration_17,
		avg_accelerations[18] AS acceleration_18,
		avg_accelerations[19] AS acceleration_19,
		avg_accelerations[20] AS acceleration_20,
		avg_accelerations[21] AS acceleration_21,
		avg_accelerations[22] AS acceleration_22,
		avg_accelerations[23] AS acceleration_23,
		avg_accelerations[24] AS acceleration_24,
		avg_accelerations[25] AS acceleration_25,
		avg_accelerations[26] AS acceleration_26,
		avg_accelerations[27] AS acceleration_27,
		avg_accelerations[28] AS acceleration_28,
		avg_accelerations[29] AS acceleration_29,
		avg_freqs[1] AS freq_1,
		avg_freqs[2] AS freq_2,
		avg_freqs[3] AS freq_3,
		avg_freqs[4] AS freq_4,
		avg_freqs[5] AS freq_5,
		avg_freqs[6] AS freq_6,
		avg_freqs[7] AS freq_7,
		avg_freqs[8] AS freq_8,
		avg_freqs[9] AS freq_9,
		avg_freqs[10] AS freq_10,
		avg_freqs[11] AS freq_11,
		avg_freqs[12] AS freq_12,
		avg_freqs[13] AS freq_13,
		avg_freqs[14] AS freq_14,
		avg_freqs[15] AS freq_15,
		avg_freqs[16] AS freq_16,
		avg_freqs[17] AS freq_17,
		avg_freqs[18] AS freq_18,
		avg_freqs[19] AS freq_19,
		avg_freqs[20] AS freq_20,
		avg_freqs[21] AS freq_21,
		avg_freqs[22] AS freq_22,
		avg_freqs[23] AS freq_23,
		avg_freqs[24] AS freq_24,
		avg_freqs[25] AS freq_25,
		avg_freqs[26] AS freq_26,
		avg_freqs[27] AS freq_27,
		avg_freqs[28] AS freq_28,
		avg_freqs[29] AS freq_29
		
	FROM
		(
		SELECT
			hex_id,
			geom,
			array_agg(avg_speed) AS avg_speeds,
			array_agg(avg_acceleration) AS avg_accelerations,
			array_agg(freq) AS avg_freqs
		FROM
			(
			SELECT
				hexs.hex_id AS hex_id,
				hexs.geom AS geom,
				hexs.minute AS MINUTE,
				avg(p.speed)::NUMERIC(10,
				0) AS avg_speed,
				avg(p.acceleration)::NUMERIC(10,
				2) AS avg_acceleration,
				count(p.*)::SMALLINT AS freq
			FROM
				(
				SELECT
					hex_id,
					minute_bin AS minute,
					geom
				FROM
					hexagons
				CROSS JOIN minute_bins 
				) AS hexs
			INNER JOIN 
			    points p ON
				(CASE 
					WHEN z < threshold_zoom THEN  hexs.hex_id = p.hex_id_13
					ELSE  hexs.hex_id = p.hex_id_14
				END)
				AND hexs.minute = p.minute
			WHERE
				p.geom && margin_tile_geom
				AND ( vehicle_types is null  or p.vehicle_type = ANY(vehicle_types))
 
			GROUP BY
				hexs.hex_id,
				hexs.geom,
				hexs.minute

		) AS subquery
		GROUP BY
			hex_id,
			geom
    ) AS avg_points
  ) AS tile
WHERE
	geom IS NOT NULL;

RETURN mvt;
END
$function$
;
