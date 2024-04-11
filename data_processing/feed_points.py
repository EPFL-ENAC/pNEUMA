import psycopg2
import csv
import sys
import time
import os
from dotenv import load_dotenv
from psycopg2.extras import execute_batch

# Load environment variables from .env file
load_dotenv()


def feed_points(name: str) -> None:
    # Database connection parameters - update these with your details


    # Get variables from environment
    dbname = os.getenv('DB_NAME')
    user = os.getenv('DB_USER')
    password = os.getenv('DB_PASSWORD')
    host = os.getenv('DB_HOST')
    port = os.getenv('DB_PORT')

    try:
        conn = psycopg2.connect(
            dbname=dbname,
            user=user,
            password=password,
            host=host,
            port=port
        )
        print("Database connection established successfully.")
    except psycopg2.DatabaseError as e:
        print(f"Database connection failed: {e}")
        sys.exit(1)
        
    cur = conn.cursor()
    # Set the schema you want to use
    schema_name = "pneuma"  # Replace with the name of your schema
    # cur.execute(f'SET search_path TO "{schema_name}"')

    # Open your CSV file
    with open(name, 'r') as f:
        reader = csv.reader(f)
        next(reader)  # Skip the header

        # Buffer for batch insert
        buffer = []
        batch_size = 10000  # Adjust the batch size as needed

        for row in reader:
            vehicle_id,vehicle_type,lat,lon,speed,acceleration,timestamp,hex_id_13,hex_id_14 = row
            # Remove existing trajectory for this id
            # cur.execute("DELETE FROM points WHERE id = %s AND timestamp = %s", (id, timestamp))
            # Create a POINT geometry from lat and lon
            # ST_GeomFromText function constructs geometry from WKT (Well-Known Text) representation
            # 'POINT(lon lat)' is the WKT representation for a point
            point_wkt = f"POINT({lon} {lat})"
            buffer.append((vehicle_id, vehicle_type, speed, acceleration, timestamp,hex_id_13,hex_id_14, point_wkt))

            # Execute batch insert when buffer reaches batch size
            if len(buffer) >= batch_size:
                execute_batch(cur, """
                INSERT INTO points (vehicle_id, vehicle_type, speed, acceleration, timestamp, hex_id_13,hex_id_14, geom) 
                VALUES (%s, %s, %s, %s, %s, %s, %s,%s, public.ST_SetSRID(public.ST_GeomFromText(%s), 4326))
                """, buffer)
                buffer.clear()  # Clear the buffer after batch insert
                print(f"Inserted {batch_size} records")
        # Insert remaining records
        if buffer:
            execute_batch(cur, """
            INSERT INTO points (vehicle_id, vehicle_type, speed, acceleration, timestamp, hex_id_13,hex_id_14, geom) 
            VALUES (%s, %s, %s, %s, %s, %s, %s,%s, public.ST_SetSRID(public.ST_GeomFromText(%s), 4326))
            """, buffer)

    conn.commit()
    cur.close()
    conn.close()

def main():
    if len(sys.argv) != 2:
        print("Usage: python script.py <file_path>")
        sys.exit(1)

    start_time = time.time()
    file_name = sys.argv[1]
    feed_points(file_name)
    end_time = time.time()
    print(f"Points fed in {end_time - start_time} seconds")

if __name__ == '__main__':
    main()
