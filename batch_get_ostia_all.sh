#!/bin/bash

# Check if the input file exists
if [ $# -ne 1 ]; then
    echo "Usage: $0 input_file"
    exit 1
fi

input_file="$1"

if [ ! -f "$input_file" ]; then
    echo "Error: Input file $input_file not found"
    exit 1
fi

# Read the file line by line
while read -r year1 month1 day1 year2 month2 day2 || [ -n "$year1" ]; do
    # Skip empty lines
    if [ -z "$year1" ]; then
        continue
    fi
    
    # Format dates as YYYY-MM-DD
    date1="${year1}-${month1}-${day1}"
    date2="${year2}-${month2}-${day2}"
    
    echo "Processing dates: $date1 and $date2"
    python3 get_ostia_all.py "$date1" "$date2"
    
    # Add a separator between outputs
    echo "----------------------------------------"
done < "$input_file"
