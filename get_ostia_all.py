"""
Python3 script to download ostia sea surface reanalysis data.
Currently the whole dataset for the globe is downloaded!

This version is dedicated to work on the super-computing
cluster "Eddy" at the University of Oldenburg.

DEPENDENCIES: 1) Account for downloading data (USERNAME/PASSWORD)
              2) python3 with modules: os, subprocess, datetime, calendar
              3) path to place ostia data

USAGE: module load netCDF-Fortran/4.4.4-intel-2016b Python
       python3 get_ostia.py

2017-05-23 - V0 - Basics
2017-07-11 - V1 - File Conversion Working
2018-05-31 - V2 - DTU Conversion adapted
2020-06-12 - V3 - Adapt

TODO:

author(s): Martin Doerenkaemper

(c) Fraunhofer IWES
"""
import os
import re
import sys
import glob
import subprocess
import datetime
import calendar
import copernicusmarine
import pexpect
import sys
# from datetime import datetime,timedelta
import shutil
import glob
# Enter username and passwort for OSTIA data download
username="xia.sun@noaa.gov"
password="_@mvV*DYw4iGjky"

CONVERTER="./converter/interpOSTIA"
MPATH="./motu-client-python/motu-client.py"
PPATH="/Library/Frameworks/Python.framework/Versions/3.10/bin/python3"
RMHOST="http://nrt.cmems-du.eu/motu-web/Motu" #"http://cmems.isac.cnr.it/motu-web/Motu" #mis-gateway-servlet/Motu

def get_date_range(sdate, edate):
    """Generate list of dates between start and end date"""
    start_date = sdate
    end_date = edate
    
    date_list = []
    current_date = start_date
    
    while current_date <= end_date:
        date_list.append(current_date.strftime('%Y-%m-%d'))
        current_date += datetime.timedelta(days=1)
    
    return date_list

def run_copernicus_download(username, password, target_date,sdate,dpath):
    """Download data for a single date"""
    datetime_str = f"{target_date}"
    target_date = datetime.datetime.strptime(target_date, "%Y-%m-%d")  # Convert string to datetime
    tmin = target_date.strftime("%Y-%m-%d %H:00:00")
    ts=target_date+datetime.timedelta(days=1)
    tmax=ts.strftime("%Y-%m-%d %H:00:00")
    opath=dpath+"orig_all/"+sdate.strftime("%Y")+"/"+target_date.strftime("%Y%m")
    if not os.path.exists(opath):
        os.makedirs(opath)
    ofile="ostia_all."+target_date.strftime("%Y%m%d")+".nc"
    # Pattern to match the downloaded file
    pattern = f"METOFFICE-GLO-SST-L4-NRT-OBS-SST-V2*{datetime_str}*.nc"

    command = f'''python3 -c "import copernicusmarine; copernicusmarine.subset(
        dataset_id='METOFFICE-GLO-SST-L4-NRT-OBS-SST-V2',
        variables=['analysed_sst', 'analysis_error', 'mask', 'sea_ice_fraction'],
        minimum_longitude=-90.78718035960358,
        maximum_longitude=-49.83475443037671,
        minimum_latitude=20.649234170676596,
        maximum_latitude=54.776255778365666,
        start_datetime='{datetime_str}T00:00:00',
        end_datetime='{datetime_str}T00:00:00')"'''


    try:
        child = pexpect.spawn(command)
        
        child.expect('Copernicus Marine username: ')
        child.sendline(username)
        
        child.expect('Copernicus Marine password: ')
        child.sendline(password)
        
        child.expect(pexpect.EOF)
        
        print(f"Successfully downloaded data for {target_date}")
        print(pattern)

        downloaded_files = glob.glob(pattern)
        print(downloaded_files)
        downloaded_file = downloaded_files[0]  # Take the first matching file
        shutil.move(downloaded_file, os.path.join(opath, ofile))

        return True
        
    except Exception as e:
        print(f"Error downloading data for {target_date}: {str(e)}")
        return False

def validate_date(date_str):
    """Validate date format"""
    try:
        datetime.datetime.strptime(date_str, '%Y-%m-%d')
        return True
    except ValueError:
        return False

def downdat(dpath,adate):
    """
    Function to Download Ostia Data given.
    Invokes the motu-client with python2
    """
    #ppath="/usr/bin/python"
    #mpath="/nfs/group/fw/ana/ostia/getdata/motu-client-python/motu-client.py"
    if adate.year >= 2007:
        rmpath="SST_GLO_SST_L4_NRT_OBSERVATIONS_010_001-TDS" # 2007--2018
        hname="METOFFICE-GLO-SST-L4-NRT-OBS-SST-V2" # 2007--2018
    else:
        rmpath="SST_GLO_SST_L4_REP_OBSERVATIONS_010_011-TDS"
        hname="METOFFICE-GLO-SST-L4-RAN-OBS-SST"
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    xmin=-179.97500610351562
    xmax=179.97500610351562
    ymin=-89.9749984741211
    ymax=89.9749984741211
    tmin=adate.strftime("%Y-%m-%d %H:00:00")
    ts=adate+datetime.timedelta(days=1)
    tmax=ts.strftime("%Y-%m-%d %H:00:00")
    opath=dpath+adate.strftime("%Y")+"/"+adate.strftime("%Y%m")
    if not os.path.exists(opath):
        os.makedirs(opath)
    ofile="ostia_all."+adate.strftime("%Y%m%d")+".nc"
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    url0=PPATH+" "+MPATH
    url1=" -u "+USERNAME+" -p "+PASSWORD+" -m "+RMHOST+" -s "+rmpath+" -d "+hname
    url2=" -x "+str(xmin)+" -X "+str(xmax)+" -y "+str(ymin)+" -Y "+str(ymax)+" -t "+tmin+" -T "+tmax
    url3=" -v analysed_sst -v sea_ice_fraction -v mask -o "+opath+" -f "+ofile+" >& "+ofile+".log"
    url=url0+url1+url2+url3
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    print("+++++ Downloading: "+ofile+"  +++++")
    print(url)
    if not os.path.exists(opath+"/"+ofile):
        try:
            subprocess.run(url,shell=True,timeout=500,check=True)
            print("+++++ Done! +++++")
        except:
            print("----- Download failed ----")
    else:
        print("----- File exists! -----")
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    return("Done!")


def convfiles(sdate,edate):
    """
    Function that converts the OSTIA data to WRF Intermediate
    """
    opathb="./wrf-interm-globe/"
    adate=sdate
    while adate<=edate:
        flist=glob.glob("./orig_all/*/*/ostia_all*.nc")
        date1=adate-datetime.timedelta(days=1)
        date2=adate
        print (flist)
        for fl in flist:
            print (fl)
            print("ostia_all."+date1.strftime("%Y%m%d")+".nc")
            print("ostia_all."+date2.strftime("%Y%m%d")+".nc")
            if "ostia_all."+date1.strftime("%Y%m%d")+".nc" in fl:
                fn1=fl
            if "ostia_all."+date2.strftime("%Y%m%d")+".nc" in fl:
                fn2=fl
        proc=CONVERTER+" "+fn1+" "+fn2
        print("+++++ Converting to WRF-INTERM: "+fn2+"  +++++")
        subprocess.run(proc,shell=True,timeout=500,check=True)
        # Move Files
        fls=glob.glob("SST*")
        for fl1 in fls:
            dlist=re.split(":|-|_",fl1)
            opath=opathb+dlist[1]+"/"+dlist[1]+dlist[2]+"/"
            if not os.path.exists(opath):
                os.makedirs(opath)
            mvproc="mv "+fl1.replace(":","\:")+" "+opath+fl1.replace("SST:","OSTIA\:")
            subprocess.run(mvproc,shell=True,timeout=500,check=True)
            print("+++++ Done! +++++")
        adate=adate+datetime.timedelta(days=1)
    return(None)


def getfiles(sdate,edate,dpath):
    """
    Function to get the Files to Download with the function downdat.
    Data are downloaded and stored in a YYYYMM/MM/ folder structure
    In: sdate, edate - End and start Date
        opath - Path for output files
    Out: MERRA2 data files
    Dependencies: downdat(urlin)
    """
    adate=sdate
    dpath=dpath+"orig_all/"
    while adate<edate:
	    dstat=downdat(dpath,adate)
	    adate=adate+datetime.timedelta(days=1)
    return("Done")

def main():
    pass
    # Define Start and End Date for Download, note that only full months
	# work (e.g. 2017-02-01 to 2018-06-01)

    # Define Start and End Date for Download, note that only full months
    sdate=datetime.datetime.strptime(sys.argv[1],"%Y-%m-%d")
    edate=datetime.datetime.strptime(sys.argv[2],"%Y-%m-%d")

    dpath="./"
    # Get list of dates to process
    dates_to_process = get_date_range((sdate- datetime.timedelta(days=1)), edate)
    total_dates = len(dates_to_process)
   # Track success/failure
    successful_downloads = 0
    failed_downloads = 0
    
    # Process each date
    for i, current_date in enumerate(dates_to_process, 1):
        print(f"\nProcessing date {i}/{total_dates}: {current_date}")
        
        if run_copernicus_download(username, password, current_date,sdate,dpath):
            successful_downloads += 1
        else:
            failed_downloads += 1
    
    # Print summary
    print("\nDownload Summary:")
    print(f"Total dates processed: {total_dates}")
    print(f"Successful downloads: {successful_downloads}")
    print(f"Failed downloads: {failed_downloads}")


    # Download Data:
    # gstat=getfiles(sdate,edate,dpath)
    # Convert Data to WRF Intermediate Files:
    cstat=convfiles(sdate,edate)

    print("Conversion Done!")


if __name__ == '__main__':
  main()
