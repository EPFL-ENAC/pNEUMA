
-- Create the points table with ENUM type for vehicle_type
CREATE TABLE points (
    vehicle_id INT NOT NULL,
    vehicle_type VARCHAR NOT NULL,
    lat FLOAT8,
    lon FLOAT8,
    speed FLOAT4,
    acceleration FLOAT4,
    timestamp INT4 NOT NULL,
    hex_id_13 H3INDEX NOT NULL,
    hex_id_14 H3INDEX NOT NULL,
    PRIMARY KEY (vehicle_id, timestamp)
);

-- Create indexes
CREATE INDEX idx_points_vehicle_type ON points (vehicle_type);
CREATE INDEX idx_points_hex_id_13 ON points (hex_id_13);
CREATE INDEX idx_points_hex_id_14 ON points (hex_id_14);

CREATE TABLE public.segments (
	vehicle_id int4 NOT NULL,
	vehicle_type varchar NOT NULL,
	speed float4 NULL,
	acceleration float4 NULL,
	t0 int4 NOT NULL,
	t1 int4 NOT NULL,
	geom public.geometry(linestring, 4326) NOT NULL,
	segment_index int4 NOT NULL,
	res float4 NOT NULL,
	progression int4 NULL,
	CONSTRAINT segments_unique UNIQUE (vehicle_id, segment_index, res)
);
CREATE INDEX segments_geom_idx ON public.segments USING gist (geom);
CREATE INDEX segments_res_idx ON public.segments

