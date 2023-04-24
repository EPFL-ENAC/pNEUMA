# pNEUMA webmap documentation

### Prerequisites

To utilize this webmap template, you will need a geospatial dataset. Ensure that your dataset is in the geoJSON format before proceeding. You can use Python's `geopandas` library to convert your dataset to the required format. Here's an outline of the steps:

1. Read your dataset as a DataFrame.
2. Create a list of geometries (points, lines, or polygons, as appropriate for your data).
3. Convert the DataFrame to a GeoDataFrame.
4. Add the list of geometries to the GeoDataFrame.
5. Save the GeoDataFrame in the geoJSON format.

For more detailed guidance, refer to the `/data_processing/refactor.py` file.

### 1. Convert geoJSON to .mbtiles

Before starting, ensure that you have installed `tippecanoe`:

    $ brew install tippecanoe

To tile your geoJSON data, you have two options:

**Option 1**: Convert the geoJSON data to `.mbtiles` format:

    $ tippecanoe -o output.mbtiles input.geojson
or

    $ tippecanoe -zg -o out.mbtiles --drop-densest-as-needed in.geojson

**Option 2**: Tile the geoJSON data into a `{Z}-{X}-{Y}.rbf` format:

    $ tippecanoe -zg --no-tile-compression -l data *.geojson -e tiles --force --drop-densest-as-needed

or 

    $ tippecanoe -Z 0 -z 22 --no-tile-compression -l data *.geojson -e tiles --force --drop-densest-as-needed

Replace `*.geojson` with the input data and `tiles` with the output folder.

Alternatively, you can run the following command before executing the above commands:

    $ docker run -it --rm -v ~/Desktop/path/to/your/webmap:/data klokantech/tippecanoe sh

The final step is to upload your tiled data to an online server. This is necessary for the upcoming steps, where we will be importing data that follows the Vector XYZ URL format (e.g., https://example.com/data/tile/{x}/{y}/{z}.pbf).

---
**💡 NOTE: Undetstanding the context**

Before proceeding, it's crucial to comprehend the purpose of the steps you're about to take. As mentioned in the `README.md` file of the webmap template, you only need to modify the `.env` file, which points to two JSON files. Specifically, the `.env` file contains two variables:

- `VITE_PARAMETERS_URL` refers to the frontend configuration of the webmap (e.g., webmap coordinates and user filtering options).
- `VITE_STYLE_URL` relates to the map's styling and layers (including your data points).

We recommend creating an `/env/` folder within the webmap project, placing your two JSON files there, and pointing to them relatively from the `.env`. The code should resemble:

```javascript
VITE_PARAMETERS_URL = /env/parameters.json
VITE_STYLE_URL = /env/style.json
```

With this context in mind, the following chapters will guide you:

- **Chapter 2**: Instructions on creating your `style.json` file
- **Chapter 3**: Instructions on creating your `parameters.json` file

---

### 2. Create the style of your webmap

First, you can start with this [JSON template](https://raw.githubusercontent.com/EPFL-ENAC/EIRA-data/main/Data_vector_style/style_raster_background.json).

To create your `style.json`, consider the following three aspects:

1. **Background**: Choose an open-source background (e.g., from [Leaflet](http://leaflet-extras.github.io/leaflet-providers/preview/)) or a token-access background (e.g., directly on [Maputnik](https://maputnik.github.io/editor/#1.33/0/0)).
2. **Vector Data**: If you want to add any specific vector data to your map, you can find resources [here](https://download.geofabrik.de).
3. **Map Assembly**: Assemble everything using [maputnik](https://maputnik.github.io/editor/#1.33/0/0) by following these steps:
   1. Open an `Empty Style` map.
   2. Add data sources for the background, any vector data, and your own tiled data:
      1. Name your `Source ID` accordingly.
      2. Select "*Vector (XYZ URLs)*" for your `Source Type`.
      3. Enter the XYZ URL in `1st Tile URL`.
      4. Adjust min-max zoom, although 0-22 is a good standard practice.
   3. Your map is still empty (don't worry!),and now you can add layers:
      1. Click on `Add Layer`
      2. `ID`: This is the name and ID of your layer (choose any name you like).
      3. `Type`: Select the appropriate type for your layer.
      4. `Source`: This links the source (`Source ID`) to your map.
      5. `Source Layer`: Self-explanatory.

After adjusting the layers and achieving a satisfactory result, click on `Export` and save it as a JSON file. You will later point to this file for the `VITE_STYLE_URL` variable in the `.env` file.


### 3. Configure the parameters of your webmap

Begin by using this [JSON template](https://raw.githubusercontent.com/EPFL-ENAC/EIRA-data/feature/parameters/Data_vector_style/parameters.json) as a starting point.

Within the template, you can adjust the initial view of your webmap by modifying the latitude, longitude, and zoom level.

The template also contains `permanentLayerIds` and `selectableItems`:

- **permanentLayerIds**: These are the identifiers for layers that are always displayed on the webmap. They help maintain a consistent base layer while allowing users to toggle additional layers on or off.
- **selectableItems**: These represent the layers that users can interact with and toggle on or off. They provide a customizable experience, enabling users to focus on the data they find most relevant.

Make sure to configure these elements to match your specific requirements and the desired user experience for your webmap.



### 4. Final Steps

You should now have everything in place. As outlined in the webmap template README.md file, execute the following commands to complete the setup:

	$ npm install
	$ npm run dev
 
 If you do not have access to a CDN, you can serve your data locally by navigating to the `data_processing` folder and running:

    $ python3 -m http.server

This command will host your data locally at http://127.0.0.1:8000/. If you examine the `style.json` file, you will notice that the sources section contains the following:

``` json
"tiles": [
    "http://localhost:5173/data/tiles/{z}/{x}/{y}.pbf"
]
```

We hope your setup process was successful 👋

---
**💡 NOTE: Vector vs Raster tiles**

This project assumes the use of vector tiles. However, if you choose to work with raster tiles, the steps in this guide remain largely the same, with some adjustments needed for certain steps, such as in Chapter 2, Step 3.2.2, where you need to select the appropriate `Source Type`. Let's briefly discuss the differences between vector and raster tiles, and how to manage these differences in your project.

Raster tiles and vector tiles are two different ways to represent geospatial data on a map.

**Raster tiles** are images, typically in formats like PNG or JPEG, which depict a specific area of the map. They are pre-rendered, fixed-resolution images generated from a larger dataset. Raster tiles are generally easier to create and can display complex visualizations, but they have some drawbacks, such as large file sizes and limited interactivity.

**Vector tiles** are a more modern approach that represents map data as a set of geometries, such as points, lines, and polygons, along with their attributes. Vector tiles are smaller in size, as they only contain the raw data needed to render a map, and they are rendered on the client-side. This allows for greater interactivity, dynamic styling, and better performance on different devices and screen resolutions.

Managing raster and vector tiles has some differences:

1. **Styling**: With raster tiles, styling is baked into the images during their generation. Changes in style require generating new tilesets. On the other hand, vector tiles can be styled dynamically on the client-side, which allows for more flexibility and customization.

2. **Interactivity**: Vector tiles enable more interactivity, such as hover effects or data-driven styling, because they contain raw data that can be accessed and manipulated on the client-side. Raster tiles do not have this level of interactivity, as they are just images.

3. **Resolution and Zoom Levels**: Raster tiles can appear pixelated or blurry when zoomed in, as they have a fixed resolution. Vector tiles, on the other hand, maintain their quality and sharpness at any zoom level because they are rendered on-the-fly.

4. **Opacity**: Managing opacity is possible for both raster and vector tiles. For raster tiles, you can adjust the opacity of the entire tile image, whereas, for vector tiles, you can adjust the opacity of individual map features (e.g., lines, polygons, or points) as part of the styling process.

In summary, raster tiles are pre-rendered images with a fixed resolution, while vector tiles contain raw data and are rendered on the client-side, allowing for greater interactivity and flexibility in styling.


---