-- Enable PostGIS extension; this is required for spatial data types and functions
CREATE EXTENSION IF NOT EXISTS postgis;

-- Create the points table with ENUM type for vehicle_type
CREATE TABLE points (
    vehicle_id INT NOT NULL,
    vehicle_type vehicle_type_enum NOT NULL,
    lat FLOAT8 NOT NULL,
    lon FLOAT8 NOT NULL,
    speed FLOAT8,
    acceleration FLOAT8,
    timestamp FLOAT8 NOT NULL,
    hex_id VARCHAR(255),
    location GEOMETRY(Point, 4326) GENERATED ALWAYS AS (ST_SetSRID(ST_Point(lon, lat), 4326)) STORED,
    PRIMARY KEY (vehicle_id, timestamp)
);

-- Create indexes
CREATE INDEX idx_points_vehicle_type ON points (vehicle_type);
CREATE INDEX idx_points_timestamp ON points (timestamp);
CREATE INDEX idx_points_hex_id ON points (hex_id);
CREATE INDEX idx_points_location ON points USING GIST (location);
