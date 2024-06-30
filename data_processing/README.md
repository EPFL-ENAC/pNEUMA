# Data Processing for pNEUMA Visualization Project

This directory contains scripts and utilities for processing and managing the data used in the pNEUMA Visualization Project. It includes operations for converting, processing, and preparing datasets for visualization and further analysis.

## Overview

The `data_processing` folder is crucial for handling the extensive urban traffic datasets collected via drones. It includes scripts for processing raw data points, segmenting trajectories, generating tiles for mapping, and managing data uploads.

## Scripts and Files

- **fetch_data.py**: Python script for downloading data for specific dates and times from the server.
- **process.py**: Python script for processing raw CSV data files into processed points.
- **process_segments.py**: Python script for converting processed points into segments with specified resolution levels.
- **Makefile**: Contains rules for automating the fetching and processing tasks, including data conversion, insertion into databases, and data preparation for uploads.

## Makefile Usage

### Environment Variables

Ensure that the `.env` file is set up correctly as it includes necessary configurations like database credentials. Variables from this file are automatically exported for use in the Makefile.

### Fetching Data

Before processing any data, it is necessary to fetch it using the following commands:

- **fetch-data**: Fetches data for a specific date and list of time slots. Requires setting the `DATE` and `TIMES` variables.

  ```
  make fetch-data DATE="24/10/2018" TIMES="0800_0830 0900_0930"
  ```

  To fetch all times for a specific date:

  ```
  make fetch-data DATE="24/10/2018" TIMES="ALL"
  ```

- **fetch-all-data**: Fetches data for all predefined dates and all time slots.
  ```
  make fetch-all-data
  ```

### Processing Commands

After fetching the data, you can process it using the following commands:

- **process-points-default-directories**: Processes all CSV files in default directories specified in the Makefile.

  ```
  make process-points-default-directories
  ```

- **process-segments-all**: Processes all segments from processed point CSV files within a specified directory.

  ```
  make process-segments-all
  ```

- **convert-mbtiles-to-pmtiles**: Converts MBTiles to PMTiles for each time range in each date.

  ```
  make convert-mbtiles-to-pmtiles
  ```

- **upload-pmtiles-to-s3**: Uploads prepared PMTiles files to an Amazon S3 bucket.
  ```
  make upload-pmtiles-to-s3
  ```

### Cleaning Up

To clean up generated files and free up storage, use:

```
make clean-hexmap-tiles
```

This command deletes all hexmap MBTiles files in the specified tiles directory.

## Contribution

Contributions to the data processing scripts are welcome. Please ensure to follow the guidelines laid out in `CONTRIBUTING.md` at the root of this repository.

## Contact

For issues, questions, or contributions, please refer to the project's main repository page or contact the project maintainers directly.
