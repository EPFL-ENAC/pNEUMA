# pNEUMA webmap documentation

### Prerequisites

All you need to work with this webmap template is a geospatial dataset. Make you convert these data to a geoJSON format. For example, to do so, you can go with Python's library `geopandas`, and (a) read your dataset as a DataFrame, create a geometry list (with points, lines or polygones as the type), then convert your DF to a GeoDataFrame, add your geometry list and save it. Check out `/data_processing/refactor.py` for more info.

### 1. Convert geoJSON to .mbtiles

First things first, make sure to install tippecanoe:

    brew install tippecanoe

Then, you have two options to tile your geojson. **First** is to convert it to `.mbtiles` format, as follows:

    tippecanoe -o output.mbtiles input.geojson
or

    tippecanoe -zg -o out.mbtiles --drop-densest-as-needed in.geojson

**Second** is to tile it into a `{Z}-{X}-{Y}.rbf` format, as follows:

    tippecanoe -zg --no-tile-compression -l data *.geojson -e tiles --force --drop-densest-as-needed

or 

    tippecanoe -Z 0 -z 22 --no-tile-compression -l data *.geojson -e tiles --force --drop-densest-as-needed

Where `*.geojson` is the input data, and `tiles` is the output folder.

Alternatively, before entering the above-command, you can first run the following:

    docker run -it --rm -v ~/Desktop/path/to/your/webmap:/data klokantech/tippecanoe sh


---
**💡 NOTE: just to put everything in context**

Before continuing, it is important to understand **why** you will do what you will do. As can be read in the `README.md` of the webmap template, you only have to modify `.env` file, which point to two json files. More specifically, in the `.env` file, you will find two variables:

- `VITE_PARAMETERS_URL` refers to the configuration for the frontend of the webmap (e.g. coordinates of your webmap, as well as the filtering for the end-user);
- `VITE_STYLE_URL` refers to the sytlisation and the layers (including your datapoints) of your map.

We suggest you to create a `/env/` folder in the webmap project, put your two json files there, and point them relatively from the `.env`. The code would look like this:

    VITE_PARAMETERS_URL = /env/parameters.json
    VITE_STYLE_URL = /env/style.json

Now that you know what you need to do, you will find below:
- **chapter 2.** guides you on how to create your `sytle.json` file, and
  
- **chapter 3.** guides you on how to create your `parameters.json` file, and 

---

### 2. Create the style of your webmap
TODO :-)


(1) fond de plan
http://leaflet-extras.github.io/leaflet-providers/preview/


(2) données vectorielles spécifiques
https://download.geofabrik.de/


(3) lib python pour recupérer les vectors tile
https://osmnx.readthedocs.io/en/stable/






(2) https://maputnik.github.io/editor/#1.33/0/0 
cr;er lien entre donnee et guichet carter, se cree via fichier e style
--> via le premier lien 
le fichier JSON genere, on l ouvre, et dedans on modifie le tiles path to be an online repo where the tile folder is 

(3)
Ce dernier JSON, on le met aussi sur github

(4) on link le lien de ce JSON dans 

    docker run -it --rm -v ${pwd}:/data   klokantech/tippecanoe  sh





[16:07] Longchamp Régis
docker run -it -v ${/Users/williamwegener/}/tileserv:/data -p 8080:80 maptiler/tileserver-gl


### 3. Configure the parameters of your webmap

TODO :-)

____________________________



### 4. Final touch

You should now be all set, and as written on the webmap template README.md file, you just have to run two commands, as follows:

	$ npm install
	$ npm run dev
 
 Last but not least, for those who don't have access to CDN, you can go to your data_processing folder, and enter:

    $ python3 -m http.server

This will run a locally your data on http://127.0.0.1:8000/. Then, if you check the `style.json` file, you'll notice that the sources has:

      "tiles": [
        "http://localhost:5173/data/tiles/{z}/{x}/{y}.pbf"
      ]

Hope all went well 👋👋👋