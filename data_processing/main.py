# Import dependencies
import pandas as pd
from utils import geospatial, refactor  # , io
from absl import app, flags

# Define the flags
flags.DEFINE_string('name', "20181101_d8_1000_1030",
                    'Name (string)', short_name='n')
flags.DEFINE_integer('size', None, 'Size (integer)', short_name='s')
flags.DEFINE_integer('fixed', None, 'Fixed (integer)', short_name='x')
flags.DEFINE_integer('variable', None, 'Variable (integer)', short_name='y')

# Mark the flags as required
# flags.mark_flag_as_required('name')
flags.mark_flag_as_required('size')
flags.mark_flag_as_required('fixed')
flags.mark_flag_as_required('variable')

FLAGS = flags.FLAGS


def main(argv):
    # Access the flag values
    file_name = FLAGS.name
    size = FLAGS.size
    fixed = FLAGS.fixed
    variable = FLAGS.variable

    refacted = refactor.Refactor(file=file_name)

    refacted.all(fixed=fixed, variable=variable,
                 size=size)

    df = pd.read_csv(f"data/output/{file_name}_{size}.csv")

    gdf = geospatial.to_point(df=df)

    geospatial.save(gdf=gdf, name=f"{file_name}_{size}")


if __name__ == '__main__':
    app.run(main)
