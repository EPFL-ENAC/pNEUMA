-- Keep the ENUM type for vehicle types
DROP TYPE IF EXISTS vehicle_type_enum;
CREATE TYPE vehicle_type_enum AS ENUM ('Taxi', 'Bus', 'Heavy Vehicle', 'Medium Vehicle', 'Motorcycle', 'Car');
