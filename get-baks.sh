#!/bin/bash
#download backups from pantheon and extract them
#first setup some variables

BAK_PATH="/var/www/pantheon_bak"
DAY_FOLDER=$(date +%Y%m%d)
FULL_BAK_PATH="$BAK_PATH/$DAY_FOLDER"
WEB_PATH="/var/www/html"
FILES_PATH="wp-content/uploads"
PANTHEON_SITE="dp-wp-ap"

[ ! -d $BAK_PATH ] && mkdir $BAK_PATH

#in case we already have a backup from today, we'll remove/replace
[ -d $FULL_BAK_PATH ] && rm -rf $FULL_BAK_PATH

mkdir -p  $BAK_PATH/$DAY_FOLDER

echo -e "Downloading backups from Pantheon \n";

terminus backup:get $PANTHEON_SITE.live --element=db --to=$FULL_BAK_PATH
terminus backup:get $PANTHEON_SITE.live --element=code --to=$FULL_BAK_PATH
terminus backup:get $PANTHEON_SITE.live --element=files --to=$FULL_BAK_PATH

echo -e "Extracting Database Backup"
gunzip $FULL_BAK_PATH/*.sql.gz -f

echo -e "Importing Database Backup"
cd $WEB_PATH

#wp-cli DB import
wp db import $FULL_BAK_PATH/*.sql --allow-root
echo -e "Database Import Complete"

echo -e "Extracting Files"
tar -zxf $FULL_BAK_PATH/*files.tar.gz -C $FULL_BAK_PATH
cp -rf $FULL_BAK_PATH/files_*/. $WEB_PATH/$FILES_PATH
echo -e "File Import Complete"

echo -e "Extracting Codebase"
tar -zxf $FULL_BAK_PATH/*code.tar.gz -C $FULL_BAK_PATH
cp -rf $FULL_BAK_PATH/*_code/. $WEB_PATH

echo -e "Codebase Import Complete"
