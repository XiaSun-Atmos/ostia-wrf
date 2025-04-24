#!/usr/bin/env python3
import copernicusmarine
import pexpect
import sys
from datetime import datetime

def run_copernicus_download(username, password, start_date, end_date):
    # Format the dates to include time
    start_datetime = f"{start_date}T00:00:00"
    end_datetime = f"{end_date}T00:00:00"
    
    # Create the command that will trigger the credential prompt
    command = f'''python3 -c "import copernicusmarine; copernicusmarine.subset(
        dataset_id='METOFFICE-GLO-SST-L4-NRT-OBS-SST-V2',
        variables=['analysed_sst', 'analysis_error', 'mask', 'sea_ice_fraction'],
        minimum_longitude=-71.9398781585776,
        maximum_longitude=-45.7991032715844,
        minimum_latitude=36.05701586697366,
        maximum_latitude=54.56115988810367,
        start_datetime='{start_datetime}',
        end_datetime='{end_datetime}')"'''

    try:
        # Spawn the process
        child = pexpect.spawn(command)
        
        # Handle username prompt
        child.expect('Copernicus Marine username: ')
        child.sendline(username)
        
        # Handle password prompt
        child.expect('Copernicus Marine password: ')
        child.sendline(password)
        
        # Wait for the process to complete
        child.expect(pexpect.EOF)
        
        print(f"Download completed for period {start_date} to {end_date}!")
        
    except Exception as e:
        print(f"Error occurred: {str(e)}")
        sys.exit(1)

def validate_date(date_str):
    try:
        datetime.strptime(date_str, '%Y-%m-%d')
        return True
    except ValueError:
        return False

if __name__ == "__main__":
    # Check command line arguments
    if len(sys.argv) != 3:
        print("Usage: python sst.py YYYY-MM-DD YYYY-MM-DD")
        print("Example: python sst.py 2025-02-04 2025-02-05")
        sys.exit(1)
    
    start_date = sys.argv[1]
    end_date = sys.argv[2]
    
    # Validate date formats
    if not validate_date(start_date) or not validate_date(end_date):
        print("Error: Invalid date format. Please use YYYY-MM-DD format")
        sys.exit(1)
    
    # Replace these with your actual credentials
    USERNAME = "xia.sun@noaa.gov"
    PASSWORD = "_@mvV*DYw4iGjky"
    
    run_copernicus_download(USERNAME, PASSWORD, start_date, end_date)