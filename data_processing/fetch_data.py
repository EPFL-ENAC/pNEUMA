import argparse
import requests

def download_data_for_specific_times(date, times, base_url, submit_url, headers, drone="dX"):
    """Download data for a specific date and specific time slots."""
    for time in times:
        data = {
            'fpLocation': drone,
            'fpDate': date,
            'fpTime': time
        }

        print(f"Requesting data for {data}")
        response = requests.post(submit_url, headers=headers, data=data)
        if response.status_code == 200:
            # Assume the response contains the file content to be saved
            file_path = f"{date}_{time}_{drone}.csv"  # Customize the file format and name as needed
            with open(file_path, 'wb') as f:
                f.write(response.content)
            print(f"Data saved to {file_path}")
        else:
            print(f"Failed to download data for {drone} on {date} at {time}: Status {response.status_code}")

def main():
    # Command line argument parsing
    parser = argparse.ArgumentParser(description="Fetch drone data for specific dates and times.")
    parser.add_argument('date', type=str, help='Date in the format DD/MM/YYYY')
    parser.add_argument('times', nargs='+', help='Time slots in the format HHMM_HHMM (e.g., 0800_0830) or ALL for all times')
    args = parser.parse_args()

    # Base URL and submit URL configuration
    base_url = "https://open-traffic.epfl.ch"
    submit_url = f"{base_url}/wp-content/uploads/mydownloads.php"

    # Predefined times and dates
    all_times = ["0800_0830", "0830_0900", "0900_0930", "0930_1000", "1000_1030", "1030_1100"]
    all_dates = ["20181024", "20181029", "20181030", "20181101"]

    # Browser-like headers
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3"
    }

    # Convert date from DD/MM/YYYY to YYYYMMDD and validate
    date_formatted = ''.join(reversed(args.date.split('/')))
    if date_formatted not in all_dates:
        print("Invalid date provided. Available dates are: 24/10/2018, 29/10/2018, 30/10/2018, 01/11/2018")
        return

    # Determine time slots to download
    if args.times == ['ALL']:
        valid_times = all_times
    else:
        valid_times = [time for time in args.times if time in all_times]
        if not valid_times:
            print("No valid times provided. Please check the time slots.")
            return

    # Call function to download data for specific date and time slots
    download_data_for_specific_times(date_formatted, valid_times, base_url, submit_url, headers)

if __name__ == "__main__":
    main()
