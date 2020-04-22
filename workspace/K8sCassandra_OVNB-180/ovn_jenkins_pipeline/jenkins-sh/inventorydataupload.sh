#!/bin/bash
# This script uploads the inventory data to the mysql data table


invfilename='/tmp/devlistsql.csv'
ovn_database_user=$2
ovn_database_password=$3

function importinvdata(){

tempfile='/tmp/inventorydatalist.csv'
tempsqlfile='/tmp/importinventorydata.sql'
local invfilename=$1

if [ -e $1 ]
  then
    cat $invfilename > $tempfile
    cp $tempfile  inventorydatalist.csv
    echo "CSV data File exists and copied into a tempfile"
  else
    echo "CSV File doesn't exist"
fi


sqlfile="SET @DESC=CONCAT('Uploaded at', Now());
         SET @ENVTYPE='DEV';
         LOAD DATA LOCAL INFILE 'inventorydatalist.csv' REPLACE INTO TABLE inventory FIELDS TERMINATED BY ',' IGNORE 1 LINES ( inventoryfilepath, hostname, ipaddress ) SET descriptionofuse=@DESC,envtype=@ENVTYPE;
         UPDATE inventory set envtype='QA' WHERE hostname like 'sl73ovnapq%';
         UPDATE inventory set envtype='INTEGRATION' WHERE inventoryfilepath like 'inventories/int%' and hostname like 'sl73ovnapd%';
         UPDATE inventory set envtype='STAGING' WHERE inventoryfilepath like 'inventories/qat-stg%' and hostname like 'sl73ovnapq%';
         UPDATE inventory set envtype='', descriptionofuse='Decomissioned' WHERE inventoryfilepath like '%dc-decom/hosts';
         SHOW WARNINGS;"

echo $sqlfile > $tempsqlfile
echo "The file to import csv file to database has been created"
outputmessage=$(mysql -h sl73ovnapd112  -u$ovn_database_user -p$ovn_database_password  db < $tempsqlfile)
echo "$outputmessage"

}


importinvdata $invfilename





