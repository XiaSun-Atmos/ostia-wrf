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

# Enter username and passwort for OSTIA data download
USERNAME=" "
PASSWORD=" "

CONVERTER="./converter/interpOSTIA"
MPATH="./motu-client-python/motu-client.py"
PPATH="/usr/bin/python"
RMHOST="http://nrt.cmems-du.eu/motu-web/Motu" #"http://cmems.isac.cnr.it/motu-web/Motu" #mis-gateway-servlet/Motu

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
        for fl in flist:
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

    # Download Data:
    gstat=getfiles(sdate,edate,dpath)
    # Convert Data to WRF Intermediate Files:
    cstat=convfiles(sdate,edate)

    print("Conversion Done!")


if __name__ == '__main__':
  main()
