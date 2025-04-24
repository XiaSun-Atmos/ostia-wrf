
#!/usr/bin/env python3
import copernicusmarine
import pexpect
import sys
import os
from datetime import datetime, timedelta

def get_date_range(start_date_str, end_date_str):
    """Generate list of dates between start and end date"""
    start_date = datetime.strptime(start_date_str, '%Y-%m-%d')
    end_date = datetime.strptime(end_date_str, '%Y-%m-%d')
    
    date_list = []
    current_date = start_date
    
    while current_date <= end_date:
        date_list.append(current_date.strftime('%Y-%m-%d'))
        current_date += timedelta(days=1)
    
    return date_list

def run_copernicus_download(username, password, target_date):
    """Download data for a single date"""
    datetime_str = f"{target_date}T00:00:00"
    
    command = f'''python3 -c "import copernicusmarine; copernicusmarine.subset(
        dataset_id='METOFFICE-GLO-SST-L4-NRT-OBS-SST-V2',
        variables=['analysed_sst', 'analysis_error', 'mask', 'sea_ice_fraction'],
        minimum_longitude=-71.9398781585776,
        maximum_longitude=-45.7991032715844,
        minimum_latitude=36.05701586697366,
        maximum_latitude=54.56115988810367,
        start_datetime='{datetime_str}',
        end_datetime='{datetime_str}')"'''

    try:
        child = pexpect.spawn(command)
        
        child.expect('Copernicus Marine username: ')
        child.sendline(username)
        
        child.expect('Copernicus Marine password: ')
        child.sendline(password)
        
        child.expect(pexpect.EOF)
        
        print(f"Successfully downloaded data for {target_date}")
        return True
        
    except Exception as e:
        print(f"Error downloading data for {target_date}: {str(e)}")
        return False

def validate_date(date_str):
    """Validate date format"""
    try:
        datetime.strptime(date_str, '%Y-%m-%d')
        return True
    except ValueError:
        return False

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python sst.py YYYY-MM-DD YYYY-MM-DD")
        print("Example: python sst.py 2024-05-05 2024-05-06")
        print("Note: Set COPERNICUS_USERNAME and COPERNICUS_PASSWORD environment variables")
        sys.exit(1)
    
    # Get credentials from environment variables
    username = "xia.sun@noaa.gov"
    password = "_@mvV*DYw4iGjky"
    
    if not username or not password:
        print("Error: Please set COPERNICUS_USERNAME and COPERNICUS_PASSWORD environment variables")
        print("Example:")
        print("export COPERNICUS_USERNAME='your_username'")
        print("export COPERNICUS_PASSWORD='your_password'")
        sys.exit(1)
    
    start_date = sys.argv[1]
    end_date = sys.argv[2]
    
    # Validate dates
    if not validate_date(start_date) or not validate_date(end_date):
        print("Error: Invalid date format. Please use YYYY-MM-DD format")
        sys.exit(1)
    
    # Get list of dates to process
    dates_to_process = get_date_range(start_date, end_date)
    total_dates = len(dates_to_process)
    
    print(f"Preparing to download data for {total_dates} day(s)")
    print(f"Date range: {start_date} to {end_date}")
    
    # Track success/failure
    successful_downloads = 0
    failed_downloads = 0
    
    # Process each date
    for i, current_date in enumerate(dates_to_process, 1):
        print(f"\nProcessing date {i}/{total_dates}: {current_date}")
        
        if run_copernicus_download(username, password, current_date):
            successful_downloads += 1
        else:
            failed_downloads += 1
    
    # Print summary
    print("\nDownload Summary:")
    print(f"Total dates processed: {total_dates}")
    print(f"Successful downloads: {successful_downloads}")
    print(f"Failed downloads: {failed_downloads}")