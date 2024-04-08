-- Create the ENUM type for vehicle types
CREATE TYPE vehicle_type_enum AS ENUM ('Taxi', 'Bus', 'Heavy Vehicle', 'Medium Vehicle', 'Motorcycle', 'Car');

-- Create the trajectories table with ENUM type for vehicle_type
CREATE TABLE trajectories (
    id SERIAL PRIMARY KEY,
    vehicle_type vehicle_type_enum NOT NULL,
    traveled_d FLOAT8,
    avg_speed FLOAT8,
    trajectory_start_time FLOAT8,
    trajectory_end_time FLOAT8,
    trajectory GEOMETRY(LineString, 4326) NOT NULL
);

-- Create indexes
CREATE INDEX idx_trajectories_id ON trajectories (id);
CREATE INDEX idx_trajectories_vehicle_type ON trajectories (vehicle_type);
CREATE INDEX idx_trajectories_trajectory_start_time ON trajectories (trajectory_start_time);
CREATE INDEX idx_trajectories_trajectory_end_time ON trajectories (trajectory_end_time);
CREATE INDEX idx_trajectories_trajectory ON trajectories USING GIST (trajectory);
