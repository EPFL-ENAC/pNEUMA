import pandas as pd
import numpy as np
import geopandas as gpd
from geopandas import GeoDataFrame
from shapely.geometry import Point
from shapely.geometry import LineString


def to_point(df: pd.DataFrame,
             coordinates_name: dict = {'longitude': 'lon', 'latitude': 'lat'},
             geometry_only: bool = False) -> GeoDataFrame:
    """
    TODO DocString
    """
    longitude = coordinates_name['longitude']
    latitude = coordinates_name['latitude']

    # Create a list of Point coordinates from DataFrame
    geometry = [Point(xy) for xy in zip(df[longitude], df[latitude])]

    df.drop([longitude, latitude], axis=1, inplace=True)
    # If user prefers the function just to return the list of geometry points
    if geometry_only:
        geometry

    # Convert the DataFrame to a GeoDataFrame
    return GeoDataFrame(df, geometry=geometry)


def progression(df: pd.DataFrame) -> pd.DataFrame:

    length = [len(df[df["track_id"] == id]) for id in set(df.track_id)]
    array = [i/num for num in length for i in range(1, num+1)]

    df['progression'] = array

    return df


def to_line(gdf: GeoDataFrame | str) -> GeoDataFrame:
    """
    TODO DocString
    """

    if type(gdf) == str:
        gdf = gpd.read_file(gdf)

    gdf = gdf.sort_values(['track_id', 'type', 'time'])

    # Group the data by 'id' and create LineStrings
    gdf_grouped = gdf.groupby('track_id')['geometry'].apply(
        lambda x: LineString(x.tolist()))
    gdf_grouped = gpd.GeoDataFrame(gdf_grouped, geometry='geometry')

    # Convert the DataFrame to a GeoDataFrame
    return gdf_grouped


def save(gdf: GeoDataFrame, name: str, in_folder: bool = True, type: str = "point"):
    """
    TODO DocString
    """
    # If user want it directly stored in
    # the right folder without specifying
    if in_folder:
        folder_path = f"data/geojson/{type}_"
        gdf.to_file(f"{folder_path}{name}.geojson", driver='GeoJSON')
    else:
        gdf.to_file(f"{name}.geojson", driver='GeoJSON')
