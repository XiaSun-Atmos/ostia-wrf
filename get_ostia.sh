#!/bin/bash

# Usage: bash get_ostia.sh 2018-01-01 2018-12-31

module restore
module load netCDF-Fortran/4.4.4-intel-2016b
module load Python

python3 get_ostia_all.py $1 $2


#
