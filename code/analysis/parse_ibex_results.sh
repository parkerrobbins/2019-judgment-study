#!/bin/bash

# This is a script that parses IbexFarm output from a file called "results.txt" into individual participant files.

mkdir participants
mkdir tables_aggregated

# Remove commas to ensure correct formatting of CSVs. 
sed -i "s/If you're reading this,/If you're reading this/g" results.txt
sed -i "s/If you're reading this do not select the other sentence,/If you're reading this do not select the other sentence/g" results.txt
sed -i "s/High school graduate,/High school graduate/g" results.txt
sed -i "s/Some high school,/Some high school/g" results.txt
sed -i "s/Some college credit,/Some college credit/g" results.txt

# Divide large file into individual participant files.
csplit -f "participants/participant-" results.txt "/# Results on/" "{*}"
for x in participants/*; do mv "$x" "${x%}.txt"; done

# Give each participant file its own directory.
find participants/* -prune -type f -exec \
  sh -c 'mkdir -p "${0%.*}" && mv "$0" "${0%.*}"' {} \;

# Split each participant file into individual tables.
for d in participants/*/*.txt; do
    f=$(dirname "${d}")
    csplit -z -f "${f}/table-" ${d} "/# Columns below this comment are as follows:/" "{*}"
    # Delete participant file
    find ${f} -type f -name 'participant-*' -delete
    find ${f} -type f -name '*' -exec mv {} {}.csv \;
    find ${f} -name "*.csv" -exec sed -i '/# Columns below this comment are as follows:/d' {} + 
    find ${f} -name "*.csv" -exec sed -i 's/\.$//' {} + 
    find ${f} -name "*.csv" -exec sed -i 's/# [0-9]*. //' {} +
    z=$(find ${f} -name "*.csv")
    for i in $z; do
	cat $i | grep -v ',' | paste -s -d"," - | cat - $i > temp && mv temp $i
	sed -i '/,/!d' $i
    done
done

rm -rf participants/participant-00

for t in table-01 table-02 table-03 table-04 table-05 table-06; do 
    for d in participants/*/; do
    cat "${d}${t}.csv" >> tables_aggregated/${t}_aggregated.csv
    sed -i '/Time results were received.*/d' tables_aggregated/${t}_aggregated.csv
    done 
done

# Name columns in each file.
sed -i '1s/^/Time results were received,MD5 hash of participant'\\'s IP address,Controller name,Item number,Element number,Type,Group,PennElementType,PennElementName,Parameter,Value,EventTime,Comments\n/' tables_aggregated/table-01_aggregated.csv
sed -i '1s/^/Time results were received,MD5 hash of participant'\\'s IP address,Controller name,Item number,Element number,Type,Group,PennElementType,PennElementName,Parameter,Value,EventTime,Instruction,Comments\n/' tables_aggregated/table-02_aggregated.csv
sed -i '1s/^/Time results were received,MD5 hash of participant'\\'s IP address,Controller name,Item number,Element number,Type,Group,PennElementType,PennElementName,Parameter,Value,EventTime,Comments\n/' tables_aggregated/table-03_aggregated.csv
sed -i '1s/^/Time results were received,MD5 hash of participant'\\'s IP address,Controller name,Item number,Element number,Type,Group,PennElementType,PennElementName,Parameter,Value,EventTime,sentence1,Comments\n/' tables_aggregated/table-04_aggregated.csv
sed -i '1s/^/Time results were received,MD5 hash of participant'\\'s IP address,Controller name,Item number,Element number,Type,Group,PennElementType,PennElementName,Parameter,Value,EventTime,Comments\n/' tables_aggregated/table-05_aggregated.csv
sed -i '1s/^/Time results were received,MD5 hash of participant'\\'s IP address,Controller name,Item number,Element number,Type,Group,PennElementType,PennElementName,Parameter,Value,EventTime,uniqueid,Comments\n/' tables_aggregated/table-06_aggregated.csv







