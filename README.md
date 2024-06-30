# pNEUMA Visualization Project

Welcome to the repository for the pNEUMA Visualization Project. This platform is designed to interactively visualize the extensive urban traffic dataset collected via drones in Athens, known as the pNEUMA dataset. The platform facilitates the analysis of nearly half a million vehicle trajectories, aiding researchers and practitioners in urban traffic management and intelligent transportation systems design.

**Live Demo:** [pNEUMA Platform](https://pneuma.epfl.ch/)

## Features

- **Interactive Visualization:** Utilize background maps and traffic metrics to explore vehicle trajectories visually.
- **Data Integration:** Curated integration of the pNEUMA dataset into an Open Research Data (ORD) platform.
- **Customizable Visual Elements:** Vehicle flow, density, and speed estimation, along with heatmaps tailored through user inputs.
- **Global Accessibility:** Provides a real preview for interaction and simplifies access to specific sections of the dataset globally.

## Project Structure

```plaintext
pNEUMA/
│
├── data_processing/
│   ├── fetch_data.py         # Script to download data for specific dates and times.
│   ├── process.py            # Script to process raw CSV data into processed points.
│   ├── process_segments.py   # Script to convert processed points into segments.
│   ├── utils/
│   │   ├── geospatial.py     # Functions to convert data to geoJSON format.
│   │   └── refactor.py       # Functions for data refactoring.
│   └── Makefile              # Automates data fetching and processing tasks.
│
├── webmap/
│   ├── public/
│   │   ├── parameters/       # Configuration files for map parameters.
│   │   ├── style/            # CSS files for webmap styling.
│   │   └── ...               # Other resources.
│   ├── ...                   # Additional configuration and script files.
│   └── .env                  # Environment variables.
│
└── README.md                 # Overview and documentation for the project.
```

## Getting Started

### Data Processing

Before running the visualization platform, it is necessary to fetch and process the dataset:

1. **Fetching Data:** Use the Makefile in the `data_processing` directory to fetch data for specific dates and times:

   ```
   cd data_processing/
   make fetch-data DATE="24/10/2018" TIMES="ALL"
   ```

2. **Processing Data:** After fetching the data, process it to prepare for visualization:
   ```
   make process-points-default-directories
   ```

### Launching the Visualization Platform

Start the entire visualization platform using the root Makefile:

```
make dev-all
```

This command will open separate terminals for the frontend and start the Martin server, which serves the database through a local server. Ensure to replace the placeholder values in the Martin command (`DATABASE_URL`) with your actual database credentials.

## Contribution

Contributions are welcome! Please refer to `CONTRIBUTING.md` for how to contribute to the project, including coding standards and guidelines.

## Contact

For any inquiries, issues, or contributions, please refer to the project's main repository page or contact the project maintainers directly.
