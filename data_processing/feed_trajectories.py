import psycopg2
import csv
import sys
import time

def feed_trajectories(name: str) -> None:
    # Database connection parameters - update these with your details
    conn = psycopg2.connect(
        dbname="pneuma",
        user="postgres",
        password="password",
        host="localhost"
    )
    cur = conn.cursor()

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
                "INSERT INTO trajectories (id, vehicle_type, traveled_d, avg_speed, trajectory_start_time, trajectory_end_time, trajectory) VALUES (%s, %s, %s, %s, %s, %s, ST_SetSRID(ST_GeomFromText(%s), 4326))",
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
