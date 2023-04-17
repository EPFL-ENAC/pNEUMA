import pandas as pd
import csv


class Refactor:

    def __init__(self, file: str) -> None:
        with open(f"data/input/{file}.csv", "r") as infile:
            self.csv = list(csv.reader(infile, delimiter=";"))

        # Defines the columns (first line) and strips it
        self.cols = [c.strip() for c in self.csv[0]]
        self.data = self.csv[1:]  # Dataset without columns
        self.y_size = int(self.data[-1][0])  # Num of tot lines
        self.name = file

    def row(self, row) -> list:
        """
        TODO: docstring
        """
        # Declare yet-empty list that will contains all sublists
        refactored = []

        # Break the row into two:
        # >> Group of cols that repeats only once at the beginning (fixed columns)
        fixed_elements = row[:self.fixed]
        # >> Group of cols that repeats itself as cols instead of rows (varia columns)
        varia_elements = row[self.fixed:]

        #  Calculate the total final numbers of col in future DF
        x_size = self.fixed + self.variable

        # Iterate over variable columns to split them by chunk of self.variable
        for i in range(0, len(varia_elements), self.variable):

            # Reconstitue a clean sublist with fixed and variable columns
            sublist = fixed_elements + varia_elements[i:i+self.variable]

            # Security check
            if len(sublist) == x_size:
                refactored.append(sublist)

        print(
            f"({fixed_elements[0]}/{self.size})\tRow refactored as shape"
            + ":\t{x_size}x{len(refactored)}")

        return refactored

    def optimize_storage(self, row: list):
        """
        TODO: docstring
        """
        # Read row as a DataFrame
        df = pd.DataFrame(row, columns=self.cols)

        # Strip `type` col and join it with track_id (10KB per row saved)
        df["type"] = df["type"].str.strip()
        df["id"] = df[['track_id', 'type']].agg('_'.join, axis=1)

        # Keep only necessary columns (+90KB per row saved)
        df = df[["id", "lat", "lon", "speed", "time"]]

        # Convert lat and lon from object to float64 (0KB saved)
        df.lat = df.lat.astype("float64")
        df.lon = df.lon.astype("float64")

        # V1: Convert to float (10KB per row saved)
        # df[["time", "speed"]] = df[["time", "speed"]].astype("float32")

        # V2: Convert to float (10KB NOT saved, but more readable)
        df[["time", "speed"]] = df[["time", "speed"]].astype("float")
        df[["time", "speed"]] = df[["time", "speed"]].round(decimals=2)

        return df

    def save(self, file: pd.DataFrame, name: str) -> None:
        """
        TODO: docstring
        """
        path = f"data/output/{name}_{self.size}.csv"
        file.to_csv(path, index=False)

    def analytic(self):
        pass
        # before = datetime.now()
        # analytic = open("analytics.csv", "w")

        # after = datetime.now()
        # timelaps = round((after-before).total_seconds(),3)
        # print(f"({row[0]}/{self.total_rows})\tRow refactored
        # in {timelaps}s\tgiven {len(refactored)*x_size} data-points")
        # analytic.write(f"{row[0]},{timelaps},{len(refactored)*x_size}\n")

        # analytic.close()

    def all(self, fixed: int, variable: int,
            analytics: bool, relational: bool, size: int):
        """
        Execution Flow
        TODO: docstring
        """
        df = pd.DataFrame()

        if size > self.y_size:
            self.size = self.y_size
        else:
            self.size = size

        self.fixed = fixed
        self.variable = variable
        self.analytics = analytics  # NOT used yet
        self.relational = relational  # NOT used yet

        i = 0
        for row in self.data:
            refactored_row = self.row(row)
            optimized_row = self.optimize_storage(refactored_row)

            df = pd.concat([df, optimized_row])

            if i == size:
                break
            i += 1

        self.save(file=df, name=self.name)
