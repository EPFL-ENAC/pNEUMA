
-- Create the hexagons table
CREATE TABLE hexagons (
    hex_id H3INDEX PRIMARY KEY, -- Assuming hex_id is a bigint representation of H3 index
    geom GEOMETRY(Polygon, 4326)
);

-- Insert hexagons by using hex_id from the points table

INSERT INTO hexagons (hex_id, geom)
SELECT hex_id, h3_cell_to_boundary(hex_id)::geometry
FROM (SELECT DISTINCT hex_id_13 AS hex_id FROM points union SELECT DISTINCT hex_id_14 AS hex_id FROM points union SELECT DISTINCT hex_id_15 AS hex_id FROM points) AS test;



CREATE INDEX idx_hexagons_ids ON hexagons (hex_id);
CREATE INDEX idx_hexagons_geom ON hexagons USING GIST (geom);


ALTER TABLE points
ADD CONSTRAINT fk_points_hexagons_14
FOREIGN KEY (hex_id_14)
REFERENCES hexagons (hex_id);

ALTER TABLE points
ADD CONSTRAINT fk_points_hexagons_15
FOREIGN KEY (hex_id_15)
REFERENCES hexagons (hex_id);


-- small tile
EXPLAIN ANALYZE
SELECT avg_points.hex_id, avg_speed, hexagons.geom
FROM (
    SELECT hex_id_14 as hex_id, AVG(speed) AS avg_speed
    FROM points p
    WHERE p.geom && ST_Transform(ST_TileEnvelope(19,296703,202255), 4326)
    GROUP BY hex_id_14
) AS avg_points
LEFT JOIN hexagons ON avg_points.hex_id = hexagons.hex_id;


--larger tile
EXPLAIN ANALYZE
SELECT avg_points.hex_id, avg_speed, hexagons.geom
FROM (
    SELECT hex_id_15 as hex_id, AVG(speed) AS avg_speed
    FROM points p
    WHERE p.geom && ST_Transform(ST_TileEnvelope(14,9272,6319), 4326)
    GROUP BY hex_id_15
) AS avg_points
LEFT JOIN hexagons ON avg_points.hex_id = hexagons.hex_id;

explain analyze
SELECT * FROM public.speed_hexmap(19, 296698, 202256, '{"vehicle_types": ["Taxi","Car"]}');


explain analyze verbose
select count(*) from points p where p.vehicle_type = 'Heavy Vehicle' and timestamp between 10 and 15;

select max(speed), min(speed), avg(speed),med(speed) from points;

select max(avg_speed), min(avg_speed), avg(avg_speed) from (
SELECT
		  hex_id_14 -- Assumed default resolution is 15
	      AS hex_id,
	        AVG(speed) AS avg_speed, AVG(acceleration) as avg_acceleration
      	FROM points p
      	GROUP by
	      	 hex_id_14 -- Assumed default resolution is 15
	      	 )
	      	 
SELECT 
    width_bucket(avg_speed, 0, 250, 100) AS bin, 
    COUNT(*) AS frequency,
    MIN(avg_speed) AS bin_min,
    MAX(avg_speed) AS bin_max
FROM 
    (SELECT
		  hex_id_14 -- Assumed default resolution is 15
	      AS hex_id,
	        AVG(speed) AS avg_speed, AVG(acceleration) as avg_acceleration
      	FROM points p
      	GROUP by
	      	 hex_id_14 -- Assumed default resolution is 15
	      	 ) 
GROUP BY 
    bin 
ORDER BY 
    bin;

SELECT
		  hex_id_15 -- Assumed default resolution is 15
	      AS hex_id,
	        AVG(speed) AS avg_speed, AVG(acceleration) as avg_acceleration, count(*) as freq
      	FROM points p
      	GROUP by
	      	 hex_id_15 -- Assumed default resolution is 15
	      	 
	      	 
	      	 
--ALTER TABLE points
--DROP CONSTRAINT fk_points_hexagons_14;
--
--ALTER TABLE points
--DROP CONSTRAINT fk_points_hexagons_15;


