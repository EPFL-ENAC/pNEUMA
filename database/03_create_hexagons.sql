
-- Create the hexagons table
CREATE TABLE hexagons (
    hex_id H3INDEX PRIMARY KEY, -- Assuming hex_id is a bigint representation of H3 index
    geom GEOMETRY(Polygon, 4326)
);

-- Insert hexagons by using hex_id from the points table

-- INSERT INTO hexagons (hex_id, geom)
-- SELECT hex_id, h3_cell_to_boundary(hex_id)::geometry
-- FROM (SELECT DISTINCT hex_id_13 AS hex_id FROM points union SELECT DISTINCT hex_id_14 AS hex_id FROM points) AS test;



CREATE INDEX idx_hexagons_ids ON hexagons (hex_id);
CREATE INDEX idx_hexagons_geom ON hexagons USING GIST (geom);

ALTER TABLE points
ADD CONSTRAINT fk_points_hexagons_13
FOREIGN KEY (hex_id_13)
REFERENCES hexagons (hex_id);


ALTER TABLE points
ADD CONSTRAINT fk_points_hexagons_14
FOREIGN KEY (hex_id_14)
REFERENCES hexagons (hex_id);




