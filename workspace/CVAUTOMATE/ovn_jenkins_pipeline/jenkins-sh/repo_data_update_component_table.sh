#!/bin/bash
# File: repo_data_update_component_table.sh
# Purpose:
#     create sql dump from python script repo_data_retrieve_for_component_table.py and upload it to OVN Component table.
#
# To run script:
#     repo_data_update_component_table.sh ovn_database_user ovn_database_password
#

ovn_database_user=$1
ovn_database_pass=$2

echo -e "\n\n-----Creat repo_data_upload.sql file------"
cat > /tmp/repo_data_upload.sql <<EOL
SET @STATUS='ACTIVE';
LOAD DATA LOCAL INFILE '/tmp/repo_data_upload.csv' INTO TABLE component FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES (cname, keywords) SET status=@STATUS;
SHOW WARNINGS;
EOL

cat /tmp/repo_data_upload.sql

echo -e "\n\n-----Upload data to OVN Component table -----"
/usr/bin/mysql -h sl73ovnapd112 -P 3306 -u$ovn_database_user -p$ovn_database_pass  db < "/tmp/repo_data_upload.sql"