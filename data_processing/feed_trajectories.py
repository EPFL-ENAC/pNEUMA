import psycopg2
import csv
import sys
import time
import os
from dotenv import load_dotenv

load_dotenv()


def feed_trajectories(name: str) -> None:
    # Database connection parameters - update these with your details
    
    # Get variables from environment
    dbname = os.getenv('DB_NAME')
    user = os.getenv('DB_USER')
    password = os.getenv('DB_PASSWORD')
    host = os.getenv('DB_HOST')

    conn = psycopg2.connect(
        dbname=dbname,
        user=user,
        password=password,
        host=host
    )

    cur = conn.cursor()
    # Set the schema you want to use
    schema_name = "pneuma"  # Replace with the name of your schema
    cur.execute(f'SET search_path TO "{schema_name}"')

    # Open your CSV file
    with open(name, 'r') as f:
        reader = csv.reader(f)
        next(reader)  # Skip the header
        for row in reader:
            id, vehicle_type, traveled_d, avg_speed, start_time, end_time, trajectory = row
            # Remove existing trajectory for this id
            cur.execute("DELETE FROM trajectories WHERE id = %s", (id,))

            # Use the trajectory directly as it's already in WKT format
            cur.execute(
                "INSERT INTO trajectories (id, vehicle_type, traveled_d, avg_speed, trajectory_start_time, trajectory_end_time, trajectory) VALUES (%s, %s, %s, %s, %s, %s, public.ST_SetSRID(public.ST_GeomFromText(%s), 4326))",
                (id, vehicle_type, traveled_d, avg_speed, start_time, end_time, trajectory)
            )

    conn.commit()
    cur.close()
    conn.close()

def main():
    if len(sys.argv) != 2:
        print("Usage: python script.py <file_path>")
        sys.exit(1)

    start_time = time.time()
    file_name = sys.argv[1]
    feed_trajectories(file_name)
    end_time = time.time()
    print(f"Trajectories fed in {end_time - start_time} seconds")

if __name__ == '__main__':
    main()
