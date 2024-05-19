import argparse
from decimal import Decimal
import time
import pandas as pd
import geopandas as gpd
import numpy as np
import movingpandas as mpd
import concurrent.futures


# Function to split a list into N parts
def split_list(lst, num_splits):
    split_size = len(lst) // num_splits
    return [lst[i:i + split_size] for i in range(0, len(lst), split_size)]

# Function to generalize each subcollection
def generalize_subcollection(sub_tc, tolerance):
    generalizer = mpd.TopDownTimeRatioGeneralizer(sub_tc)
    return generalizer.generalize(tolerance=tolerance)

def generalize_trajectories(trajectories, num_splits, tolerance_meters):
    # Calculate tolerance in degrees, assuming meters to degrees conversion at the equator
    tolerance_degrees = tolerance_meters / 111320  # Conversion factor at equator

    # Split the list of trajectories into N parts
    sub_collections = [mpd.TrajectoryCollection(trajectories_chunk) for trajectories_chunk in split_list(trajectories, num_splits)]

    # Using ProcessPoolExecutor to parallelize the task
    with concurrent.futures.ProcessPoolExecutor() as executor:
        futures = [executor.submit(generalize_subcollection, sub, tolerance_degrees) for sub in sub_collections]
        results = [future.result() for future in concurrent.futures.as_completed(futures)]

    # Combine results back into a single TrajectoryCollection
    collection =  mpd.TrajectoryCollection([traj for result in results for traj in result])
    collection.add_speed(units=("km", "h"),overwrite=True)
    collection.add_acceleration(overwrite=True)
    return collection

def calculate_progression(group):
    num_segments = len(group)
    group['progression'] = np.linspace(0, 100, num_segments).astype(int)
    return group


def wrangle_gdf(gdf,res):

    gdf['t0'] = gdf['timestamp'] - (gdf['t'].astype('datetime64[ms]').astype('int64') - gdf['prev_t'].astype('datetime64[ms]').astype('int64'))
    gdf.rename(columns={'timestamp':'t1','geometry':'geom'},inplace=True)
    gdf.drop(['t','prev_t'],axis=1,inplace=True)
    gdf['segment_index'] = gdf.groupby('vehicle_id',sort=True).cumcount()+1
    gdf = gdf.groupby('vehicle_id',sort=True).apply(calculate_progression).reset_index(drop=True)
    gdf['speed'] = gdf['speed'].astype(int)
    gdf['acceleration'] = gdf['acceleration'].apply(lambda x: Decimal("{:.2f}".format(x)).normalize())
    gdf['res'] = Decimal(res).normalize()
    return gdf




def main(input_file, output_prefix, res_levels=[10, 3, 0.5, 0.1]):
    start_time = time.time()  # Start time
    print("Starting data processing...")

    # Read CSV file
    print("Reading CSV file...")
    csv_start_time = time.time()
    gdf = pd.read_csv(input_file)
    gdf['timestamp'] = pd.to_numeric(gdf['timestamp'], errors='coerce')
    start_recording_datetime = pd.to_datetime('2018-10-24 08:30:00')
    gdf['datetime'] = pd.to_timedelta(gdf['timestamp'], unit='milliseconds') + start_recording_datetime
    gdf.drop(['speed', 'acceleration', 'hex_id_14', 'hex_id_13'], axis=1, inplace=True)
    csv_end_time = time.time()
    print(f"CSV file read in {csv_end_time - csv_start_time:.2f} seconds.")

    print(f"\nCreating TrajectoryCollection...")
    tc_start_time = time.time()
    tc = mpd.TrajectoryCollection(gdf, 'vehicle_id', t='datetime', x="lon", y="lat")
    tc_end_time = time.time()
    print(f"TrajectoryCollection created in {tc_end_time - tc_start_time:.2f} seconds.")

    trajectories = list(tc)
    results = []

    for res in res_levels:
        print(f"\nProcessing trajectories with res={res}...")
        res_start_time = time.time()
        col = generalize_trajectories(trajectories, num_splits=16, tolerance_meters=res)
        res_end_time = time.time()
        print(f"Generalized with res={res} in {res_end_time - res_start_time:.2f} seconds.")

        wrangle_start_time = time.time()
        gdf_res = col.to_line_gdf()
        results.append(wrangle_gdf(gdf_res, res=res))
        wrangle_end_time = time.time()
        print(f"Wrangled with res={res} in {wrangle_end_time - wrangle_start_time:.2f} seconds.")
        

    res_levels_formatted = [int(res) if res.is_integer() else res for res in res_levels]

    final_df = pd.concat(results, axis=0)
    print(final_df)
    final_df.to_csv(f"{output_prefix}/segments_zoom_{'_'.join(map(str, res_levels_formatted))}.csv", index=False)

    end_time = time.time()  # End time
    time_taken = end_time - start_time
    print(f"Data processing completed in {time_taken:.2f} seconds.")


if __name__ == "__main__":
    
    parser = argparse.ArgumentParser(description="Process trajectory data.")
    parser.add_argument("input_file", help="Path to the input CSV file.")
    parser.add_argument("output_prefix", help="Path for the output CSV files.")
    parser.add_argument("--res-levels", nargs="+", type=float, default=[10, 3, 0.5, 0.1], help="Res levels for segmentation. Default: [10, 3, 0.5, 0.1]")
    args = parser.parse_args()
    print(args.input_file, args.output_prefix,args.res_levels)
    main(args.input_file, args.output_prefix,args.res_levels)
