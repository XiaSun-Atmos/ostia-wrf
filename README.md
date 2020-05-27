# OSTIA - WRF - Converter
A converter to use the Operational Sea Surface Temperature and Sea Ice Analysis (OSTIA)
data with WRF. A python wrapper script automatically downloads the data and starts the
converter that is written in Fortran. 

### 1. Purpose
OSTIA data are high resolution data of sea surface information such as sea
surface temperature and sea ice which are provided in netCDF format. To work with
this data in the context of WRF simulations, a conversion to the WRF itnernal
format is needed. The process of download and conversion 
is fully automatized in this script. The data are also interpolated in time 
from daily to six hourly files to work with the typical reanalysis data. 

### 2. Compilation and Adaptation to local system

Needed libraries

To compile change: 

and run: 




### 3. Usage

./get_ostia.sh 2017-01-01 2017-01-02

#### Developers: 
* Susumu Shimada -  AIST, Koriyama, Japan
* Martin Dörenkämper - Fraunhofer IWES, Oldenburg, Germany
* Gerald Steinfeld - ForWind University of Oldenburg, Oldenburg, Germany

    
