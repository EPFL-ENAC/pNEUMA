# Import dependencies
import pandas as pd
from modules import geospatial
from modules.refactor import Refactor

# Declare constants
CONFIG = {
    'longitude': 'lon',
    'latitude': 'lat',
}
S = 100
FILE = "20181101_d8_1000_1030"

refactor = Refactor(file=FILE)

refactor.all(fixed=4, variable=6,
             size=S,
             analytics=True, relational=False)


df = pd.read_csv(f"data/output/{FILE}_{S}.csv")

gdf = geospatial.to_point(df=df, coordinates_name=CONFIG)

geospatial.save(gdf=gdf, name=f"{FILE}_{S}")
