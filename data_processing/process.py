import multiprocessing
import sys
import time
import os
import re 
import csv
import math
import h3

chunk_size = 10  # Adjust this based on your system's memory capacity
sampling_interval = 0.5  # Change this value for different sampling, it's in seconds

use_linestring = False # If true, the output will be a linestring, otherwise it will be multiples points

## USAGE python process.py ../data/inputs/20181024_dX_0830_0900.csv 

def process_chunk(chunk_data, chunk_index, output_dir):
    processed_data = []
    start_time = time.time()

    temp_output_file = os.path.join(output_dir, f'temp_chunk_{chunk_index}.csv')
    with open(temp_output_file, 'w', newline='') as f:
        csv_writer = csv.writer(f)
        for line in chunk_data:
            data = line.strip().split(';')
            track_id = data[0]
            vehicle_type = data[1].strip()
            traveled_d = data[2]
            avg_speed = data[3]
            data_points = data[4:]  # Assuming the first 4 columns are id, type, traveled_d, avg_speed
            trajectory = []
            last_included_timestamp = None
            trajectory_start_time = None
            trajectory_end_time = None
            

            for i in range(0, len(data_points)-1, 6):
                try:
                    lat, lon, speed, lon_acc, lat_acc, timestamp = data_points[i:i+6]
                    timestamp = float(timestamp)
                    speed = float(speed)
                    lon_acc = float(lon_acc)
                    lat_acc = float(lat_acc)
                    hex_id_14 = h3.geo_to_h3(float(lat), float(lon), 14)
                    hex_id_15 = h3.geo_to_h3(float(lat), float(lon), 15)
                    hex_id_13 = h3.geo_to_h3(float(lat), float(lon), 13)
                    if last_included_timestamp is None :
                        trajectory_start_time = timestamp
                    if last_included_timestamp is None or timestamp - last_included_timestamp >= sampling_interval:
                        if not use_linestring : 
                            acceleration = math.sqrt(math.pow(lon_acc,2)+ math.pow(lat_acc,2))                            
                            processed_data.append([track_id, vehicle_type,lat, lon, speed,acceleration, timestamp,hex_id_13,hex_id_14,hex_id_15])
                        else :
                            trajectory.append(f"{lon} {lat}")     
                        last_included_timestamp = timestamp
                except ValueError as e:
                    print(f"ValueError occurred: {e}")
                    # Optional: print more details, e.g., the problematic data
                    print(f"Problematic data: {data_points[i:i+6]}")
                    print(f"In line: {track_id} index {i}")
                    continue
            trajectory_end_time = last_included_timestamp
            if len(trajectory) > 1 :
                trajectory = f"LINESTRING({','.join(trajectory)})"
                if use_linestring : 
                        processed_data.append([track_id, vehicle_type, traveled_d,avg_speed,trajectory_start_time, trajectory_end_time,trajectory])

        for row in processed_data:
            csv_writer.writerow(row)
            # f.write(','.join(map(str, row)) + '\n')

    end_time = time.time()
    print(f"Chunk {chunk_index} processed in {end_time - start_time} seconds")

def concatenate_files(output_file, output_dir):
    def sort_key(filename):
        parts = filename.split('_')
        if parts[0] == 'temp' and parts[1] == 'chunk' and parts[2].split('.')[0].isdigit():
            return int(parts[2].split('.')[0])
        return float('inf')  # Put non-matching files at the end

    with open(output_file, 'w', newline='') as f_out:
        if not use_linestring :
            f_out.write('vehicle_id,vehicle_type,lat,lon,speed,acceleration,timestamp,hex_id_13,hex_id_14,hex_id_15\n')  # Write headers here
        else : 
            f_out.write('vehicle_id,vehicle_type,traveled_d,avg_speed,trajectory_start_time,trajectory_end_time,trajectory\n')
        for filename in sorted(os.listdir(output_dir), key=sort_key):
            if filename.startswith('temp_chunk_'):
                with open(os.path.join(output_dir, filename), 'r') as f_in:
                    lines = f_in.readlines()
                    if len(lines) > 1:  # Check if there's more than just a header line
                        f_out.writelines(lines[1:])  # Skip the header line and write the rest
                os.remove(os.path.join(output_dir, filename))

def process(name: str) -> None:
    if use_linestring :
        output_file = name.replace('.csv', '_processed_lines.csv')
    else : 
        output_file = name.replace('.csv', '_processed_points.csv')
    output_dir = os.path.dirname(output_file)

    with open(name, 'r') as file:
        lines = file.readlines()
        chunks = [lines[i:i + chunk_size] for i in range(1, len(lines), chunk_size)]

    pool = multiprocessing.Pool(processes=multiprocessing.cpu_count())
    for chunk_index, chunk_data in enumerate(chunks):
        pool.apply_async(process_chunk, args=(chunk_data, chunk_index, output_dir))

    pool.close()
    pool.join()

    concatenate_files(output_file, output_dir)

def main():
    if len(sys.argv) != 2:
        print("Usage: python script.py <file_path>")
        sys.exit(1)

    start_time = time.time()
    file_name = sys.argv[1]
    process(file_name)
    end_time = time.time()
    print(f"File processed in {end_time - start_time} seconds")

if __name__ == '__main__':
    main()
