# Include .env file and export its variables
include .env
export


# Python script to be used
PYTHON_SCRIPT=process.py

# Default res levels, specified as command line arguments
RES_LEVELS=6 3 1.5 0.5 0.1

DEFAULT_FILES=20181024_dX 20181029_dX 20181030_dX 20181101_dX
DEFAULT_TIMES=0800_0830 0830_0900 0900_0930 0930_1000 1000_1030 1030_1100
DEFAULT_DATA_DIR=../data/

# Python script to be used for segment processing
SEGMENT_SCRIPT=process_segments.py


# Variable to define the base directory for uploads
UPLOAD_DIR := ../data/pmtiles_upload

# Rule to prepare pmtiles files for upload
prepare-pmtiles-upload:
	@mkdir -p $(UPLOAD_DIR)  # Create the upload directory if it doesn't exist
	@for dir in $(DEFAULT_FILES); do \
		for time_range_dir in $(DEFAULT_DATA_DIR)/$$dir/tiles/*; do \
			if [ -d $$time_range_dir ]; then \
				mkdir -p $(UPLOAD_DIR)/$$dir/$$(basename $$time_range_dir); \
				find $$time_range_dir -name '*.pmtiles' -exec cp {} $(UPLOAD_DIR)/$$dir/$$(basename $$time_range_dir)/ \;; \
			else \
				echo "No directory found for $$time_range_dir"; \
			fi; \
		done; \
	done

# Rule to upload prepared pmtiles files to S3
upload-pmtiles-to-s3:
	@s3cmd put --recursive --acl-public --guess-mime-type $(UPLOAD_DIR)/ s3://$(S3_BUCKET_NAME)/pneuma/

# Rule to convert mbtiles to pmtiles for each time range in each date
convert-mbtiles-to-pmtiles:
	@for dir in $(DEFAULT_FILES); do \
		for time_range_dir in $(DEFAULT_DATA_DIR)/$$dir/tiles/*; do \
			if [ -d $$time_range_dir ]; then \
				echo "Converting mbtiles to pmtiles in $$time_range_dir..."; \
				if [ -f $$time_range_dir/hexmap.mbtiles ]; then \
					echo "Converting hexmap.mbtiles to hexmap.pmtiles in $$time_range_dir..."; \
					pmtiles convert $$time_range_dir/hexmap.mbtiles $$time_range_dir/hexmap.pmtiles; \
				fi; \
				if [ -f $$time_range_dir/trajectories.mbtiles ]; then \
					echo "Converting trajectories.mbtiles to trajectories.pmtiles in $$time_range_dir..."; \
					pmtiles convert $$time_range_dir/trajectories.mbtiles $$time_range_dir/trajectories.pmtiles; \
				fi; \
			else \
				echo "No directory found for $$time_range_dir"; \
			fi; \
		done; \
	done


# Rule to process all CSV files in each default directory
process-points-default-directories:
	@for dir in $(DEFAULT_FILES); do \
		$(MAKE) process-points-all DIR=$(DEFAULT_DATA_DIR)/$$dir; \
	done

# Rule to process all CSV files in a specified directory
process-points-all:
	@if [ -d $(DIR) ]; then \
		echo "Processing all CSV files in directory $(DIR)"; \
		mkdir -p $(DIR)/points;\
		for file in $(DIR)/*.csv; do \
			echo "Processing $$file..."; \
			python $(PYTHON_SCRIPT) $$file $(DIR)/points; \
		done; \
	else \
		echo "Directory $(DIR) does not exist"; \
	fi


process-segments-default-directories:
	@for dir in $(DEFAULT_FILES); do \
		$(MAKE) process-points-all DIR=$(DEFAULT_DATA_DIR)/$$dir; \
	done



# Rule to process segments from processed point CSV files in a directory
process-segments-all:
	@if [ -d $(DIR)/points ]; then \
		mkdir -p $(DIR)/segments; \
		echo "Processing segments for files within directory $(DIR)/points"; \
		for file in $(DIR)/points/*_processed_points.csv; do \
			# Removing '_processed_points' from the filename
			base_name=$$(basename $$file _processed_points.csv); \
			output_segment_file=$(DIR)/segments/$${base_name}_segments.csv; \
			echo "Processing segments for $$file into $$output_segment_file..."; \
			python $(SEGMENT_SCRIPT) $$file $$output_segment_file --res-levels $(RES_LEVELS); \
		done; \
	else \
		echo "Directory $(DIR)/points does not exist"; \
	fi

# Rule to process segments from one processed point CSV file
process-segments:
	@echo "Processing segments for $(FILE)..."
	@python $(SEGMENT_SCRIPT) $(FILE) $$(dirname $(FILE))/$$(basename $(FILE) .csv)_segments --res-levels $(RES_LEVELS);


# Rule to process all CSV files in the points directory for hexmap tile generation
generate-hexmap-tiles-all:
	@echo "Generating Hexmap Tiles for all CSV files in $(DIR)/points..."
	@$(MAKE) empty-points; 
	@$(MAKE) run-database-checkpoint;
	@$(MAKE) clean-hexmap-tiles
	@for file in $(DIR)/points/*.csv; do \
		echo "Processing file $$file for Hexmap Tiles..."; \
		time_range=$$(echo $$file | sed -n 's/.*\([0-9]\{4\}_[0-9]\{4\}\).*_processed_points.*\.csv/\1/p'); \
		output_dir=$(DIR)/tiles/$$time_range; \
		mkdir -p $$output_dir; \
		$(MAKE) insert-points FILE=$$file; \
		$(MAKE) generate-hexmap-tiles DIR=$$output_dir; \
		$(MAKE) empty-points; \
		echo "Completed Hexmap Tile Generation and Cleanup for $$file in directory $$output_dir"; \
	done
	@$(MAKE) run-database-vacuum-full

# Rule to process all CSV files in the segments directory for trajectories tile generation
generate-trajectories-tiles-all:
	@echo "Generating Trajectories Tiles for all CSV files in $(DIR)/segments..."
	@$(MAKE) empty-segments; 
	@$(MAKE) run-database-checkpoint;
	@$(MAKE) clean-trajectories-tiles;
	@for file in $(DIR)/segments/*.csv; do \
		echo "Processing file $$file for Trajectories Tiles..."; \
		time_range=$$(echo $$file | sed -n 's/.*\([0-9]\{4\}_[0-9]\{4\}\).*_segments_*.*\.csv/\1/p'); \
		output_dir=$(DIR)/tiles/$$time_range; \
		mkdir -p $$output_dir; \
		$(MAKE) insert-segments FILE=$$file; \
		$(MAKE) generate-trajectories-tiles DIR=$$output_dir; \
		$(MAKE) empty-segments; \
		echo "Completed Trajectories Tile Generation and Cleanup for $$file in directory $$output_dir"; \
	done
	@$(MAKE) run-database-vacuum-full



# Rule to insert processed points into the 'points' table
insert-points:
	@echo "Inserting processed points data into PostgreSQL..."
	@echo "Inserting data from $(FILE) into points table..."
	@PGPASSWORD=$$DB_PASSWORD psql -h $$DB_HOST -p $$DB_PORT -U $$DB_USER -d $$DB_NAME -c "\copy points (vehicle_id, vehicle_type,lat,lon, speed, acceleration, timestamp, hex_id_13, hex_id_14) from '$(FILE)'  delimiter ',' csv header;"

# Rule to insert segments into the 'segments' table
insert-segments:
	@echo "Inserting segments data into PostgreSQL..."
	@echo "Inserting data from $(FILE) into segments table..."
	@PGPASSWORD=$$DB_PASSWORD psql -h $$DB_HOST -p $$DB_PORT -U $$DB_USER -d $$DB_NAME -c "\copy segments (vehicle_id, vehicle_type, t1, speed, acceleration, geom, t0, segment_index, progression, res) from '$(FILE)' csv header;"


generate-hexmap-tiles:
	martin-cp  --output-file $(DIR)/hexmap.mbtiles --mbtiles-type flat --pool-size 20 --cache-size 8192 --bbox="23.72224,37.97412,23.73979,37.99440" --on-duplicate abort --min-zoom=14 --max-zoom=17 --source hexmap "postgresql://$$DB_USER:$$DB_PASSWORD@$$DB_HOST:$$DB_PORT/$$DB_NAME"

generate-trajectories-tiles:
	martin-cp  --output-file $(DIR)/trajectories.mbtiles --mbtiles-type flat --cache-size 8192 --bbox="23.72224,37.97412,23.73979,37.99440" --on-duplicate abort --min-zoom=14 --max-zoom=19 --source trajectories "postgresql://$$DB_USER:$$DB_PASSWORD@$$DB_HOST:$$DB_PORT/$$DB_NAME"

clean-hexmap-tiles:
	@echo "Deleting all hexmap.mbtiles files in $(DIR)/tiles/..."
	@count=$$(find $(DIR)/tiles/ -name 'hexmap.mbtiles' -delete -print | wc -l); \
	echo "$$count hexmap.mbtiles files deleted."

# Rule to delete all trajectories.mbtiles files in the subdirectories of $(DIR)/tiles and report how many were deleted
clean-trajectories-tiles:
	@echo "Deleting all trajectories.mbtiles files in $(DIR)/tiles/..."
	@count=$$(find $(DIR)/tiles/ -name 'trajectories.mbtiles' -delete -print | wc -l); \
	echo "$$count trajectories.mbtiles files deleted."


run-database-checkpoint:
	@echo "Creating database checkpoint..."
	@PGPASSWORD=$$DB_PASSWORD psql -h $$DB_HOST -p $$DB_PORT -U $$DB_USER -d $$DB_NAME -c "CHECKPOINT;"

run-database-vacuum-full:
	@echo "Run vacuum full on database..."
	@PGPASSWORD=$$DB_PASSWORD psql -h $$DB_HOST -p $$DB_PORT -U $$DB_USER -d $$DB_NAME -c "VACUUM FULL;"


# Rule to empty the 'points' table
empty-points:
	@echo "Emptying the points table in PostgreSQL..."
	@PGPASSWORD=$$DB_PASSWORD psql -h $$DB_HOST -p $$DB_PORT -U $$DB_USER -d $$DB_NAME -c "TRUNCATE TABLE public.points CONTINUE IDENTITY RESTRICT;"

# Rule to empty the 'segments' table
empty-segments:
	@echo "Emptying the segments table in PostgreSQL..."
	@PGPASSWORD=$$DB_PASSWORD psql -h $$DB_HOST -p $$DB_PORT -U $$DB_USER -d $$DB_NAME -c "TRUNCATE TABLE public.segments CONTINUE IDENTITY RESTRICT;"


.PHONY: process-all process process-segments