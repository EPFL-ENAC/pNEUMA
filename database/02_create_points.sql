
-- Create the points table with ENUM type for vehicle_type
CREATE TABLE points (
    vehicle_id INT NOT NULL,
    vehicle_type vehicle_type_enum NOT NULL,
    speed FLOAT4,
    acceleration FLOAT4,
    timestamp INT4 NOT NULL,
    hex_id_13 H3INDEX NOT NULL,
    hex_id_14 H3INDEX NOT NULL,
    geom GEOMETRY(Point, 4326) not null,
    PRIMARY KEY (vehicle_id, timestamp)
);

-- Create indexes
CREATE INDEX idx_points_vehicle_type ON points (vehicle_type);
CREATE INDEX idx_points_timestamp ON points (timestamp);
CREATE INDEX idx_points_hex_id_13 ON points (hex_id_13);
CREATE INDEX idx_points_hex_id_14 ON points (hex_id_14);
CREATE INDEX idx_points_location ON points USING GIST (geom);

CREATE INDEX idx_points_timestamp_vehicle_type ON points (timestamp, vehicle_type);
