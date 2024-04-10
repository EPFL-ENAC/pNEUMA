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
  tile_margin numeric; -- Set your threshold zoom level here
  hex_area numeric; -- variable to store hexagon area
  vehicle_types vehicle_type_enum[]; -- Array to store vehicle types from query parameters
  elem text;
  start_time numeric;
  end_time numeric;

begin
	
	IF query_params->>'start_time' IS NOT NULL THEN
	    start_time := (query_params->>'start_time')::float;
	ELSE
	    start_time := NULL; -- Or some default value
	END IF;
	
	IF query_params->>'end_time' IS NOT NULL THEN
	    end_time := (query_params->>'end_time')::float;
	ELSE
	    end_time := NULL; -- Or some default value
	END IF;
	
	IF query_params->'vehicle_types' IS NOT NULL THEN
	    vehicle_types := ARRAY(SELECT json_array_elements_text(query_params->'vehicle_types')::vehicle_type_enum);
	ELSE
	    vehicle_types := '{}'; -- Assign an empty array if 'vehicle_types' is not in query_params
	END IF;    
	
	-- Check if vehicle_types array is empty and set it to null if it is
	IF vehicle_types = '{}' THEN
	    vehicle_types := NULL;
	END IF;

	IF z < 16 THEN
		hex_area := 43.870; -- Example area value for resolution 13
		tile_margin := 8;
	ELSIF z < 18 THEN
		hex_area := 6.267; -- Example area value for resolution level 14
		tile_margin := 3;
	elseif z >= 18 THEN
		hex_area := 0.895; -- Example area value for resolution level 15
		tile_margin := 1;
	END IF;

  -- Generating the MVT with pre-existing Hexagonal Grid
  SELECT INTO mvt ST_AsMVT(tile, 'speed_hexmap', 4096, 'geom') FROM (
    SELECT
      ST_AsMVTGeom(
        h.geom, -- Existing hexagonal grid geometry
        ST_Transform(ST_TileEnvelope(z, x, y), 4326),
        4096, 64, true) AS geom,
       h.hex_id as h3index,
      avg_points.avg_speed as avg_speed, -- Average speed for each hex
      avg_points.avg_acceleration as avg_acceleration,
      avg_points.freq,
	  (avg_points.freq / NULLIF(hex_area, 0))::float as density -- Calculate density

    FROM
      hexagons h
    INNER JOIN (
    	SELECT
		    CASE
	         WHEN z < threshold_zoom_14 THEN hex_id_13
	         WHEN z >= threshold_zoom_14 AND z < threshold_zoom_15 THEN hex_id_14
	         ELSE hex_id_15 -- Assumed default resolution is 15
	        END AS hex_id,
	        AVG(speed) AS avg_speed, AVG(acceleration) as avg_acceleration, count(*) as freq
      	FROM points p
		WHERE p.geom && ST_Transform(ST_Envelope(ST_Buffer(ST_TileEnvelope(z, x, y), tile_margin)), 4326)
		AND ( vehicle_types is null  or p.vehicle_type = ANY(vehicle_types))
		and ( start_time is null or end_time is null or p.timestamp between start_time and end_time)
      	GROUP by
	      	CASE
  	         WHEN z < threshold_zoom_14 THEN hex_id_13
	         WHEN z >= threshold_zoom_14 AND z < threshold_zoom_15 THEN hex_id_14
	         ELSE hex_id_15 -- Assumed default resolution is 15
	        END
    ) AS avg_points ON h.hex_id = avg_points.hex_id
  ) as tile WHERE geom IS NOT NULL;

  RETURN mvt;
END
$function$
;
