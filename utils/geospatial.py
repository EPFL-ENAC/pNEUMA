import pandas as pd
from datetime import datetime
from geopandas import GeoDataFrame
from shapely.geometry import Point


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

    df.drop([longitude, latitude], axis=1)
    # If user prefers the function just to return the list of geometry points
    if geometry_only:
        geometry

    # Convert the DataFrame to a GeoDataFrame
    return GeoDataFrame(df, geometry=geometry)


def save(gdf: GeoDataFrame, name: str, in_folder: bool = True):
    """
    TODO DocString
    """
    # If user want it directly stored in
    # the right folder without specifying
    if in_folder:
        folder_path = "data/geojson/" + datetime.today().strftime("%Y-%m-%d_")
        gdf.to_file(f"{folder_path}{name}.geojson", driver='GeoJSON')
    else:
        gdf.to_file(f"{name}.geojson", driver='GeoJSON')
