FROM postgis/postgis:16-3.4


# Install H3 (if needed)
RUN apt-get update && apt-get install -y postgresql-16-h3

# Copy your CSV data
COPY data/points_default.csv /data/points_default.csv


# Add your SQL scripts
COPY *.sql /docker-entrypoint-initdb.d/
