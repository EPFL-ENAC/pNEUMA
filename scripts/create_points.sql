
-- Enable PostGIS extension; this is required for spatial data types and functions
CREATE EXTENSION IF NOT EXISTS postgis;

-- Create the points table with ENUM type for vehicle_type
CREATE TABLE points (
    vehicle_id INT NOT NULL,
    vehicle_type vehicle_type_enum NOT NULL,
    speed FLOAT8,
    acceleration FLOAT8,
    timestamp FLOAT8 NOT NULL,
    hex_id_13 H3INDEX NOT NULL,
    hex_id_14 H3INDEX NOT NULL,
    hex_id_15 H3INDEX NOT NULL,
    geom GEOMETRY(Point, 4326) not null,
    PRIMARY KEY (vehicle_id, timestamp)
);

-- Create indexes
CREATE INDEX idx_points_vehicle_type ON points (vehicle_type);
CREATE INDEX idx_points_timestamp ON points (timestamp);
CREATE INDEX idx_points_hex_id_13 ON points (hex_id_13);
CREATE INDEX idx_points_hex_id_14 ON points (hex_id_14);
CREATE INDEX idx_points_hex_id_15 ON points (hex_id_15);
CREATE INDEX idx_points_location ON points USING GIST (geom);
