-- Create the ENUM type for vehicle types
CREATE TYPE vehicle_type_enum AS ENUM ('Taxi', 'Bus', 'Heavy Vehicle', 'Medium Vehicle', 'Motorcycle', 'Car');

-- Create the trajectories table with ENUM type for vehicle_type
CREATE TABLE segments (
    vehicle_id SERIAL PRIMARY KEY,
    vehicle_type vehicle_type_enum NOT NULL,
    distance FLOAT8,
    speed FLOAT8,
    acceleration FLOAT8,
    timestamp FLOAT8,
    trajectory GEOMETRY(LineString, 4326) NOT NULL
);

-- Create indexes
CREATE INDEX idx_segments_vehicle_id ON segments (vehicle_id);
CREATE INDEX idx_segments_vehicle_type ON segments (vehicle_type);
CREATE INDEX idx_segments_timestamp ON segments (timestamp);
CREATE INDEX idx_segments_trajectory ON segments USING GIST (trajectory);