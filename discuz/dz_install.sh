#!/bin/bash

############################
# Usage:
# File Name: dz_install.sh
# Author: annhe  
# Mail: i@annhe.net
# Created Time: 2016-04-11 18:39:16
############################

[ $# -lt 2 ] && echo "args error" && exit 1
webroot="/home/wwwroot/default"
dzsource="$webroot/dz/upload"
root=$1
host=$2
dzroot="$webroot/$root"
passwd="admin123"
dbhost="localhost"
dbname="ultrax_dz_$root"
dbuser="root"
dbpass="root123"

if [ ! -d $dzroot ];then
	mkdir $dzroot
	cp -ru $dzsource/* $dzroot
	chown -R www.www $dzroot
else
	echo "$dzroot exists!"
	exit 1
fi

url="http://$host/$root/install/index.php"
data="step=3&install_ucenter=yes&dbinfo%5Bdbhost%5D=$dbhost&dbinfo%5Bdbname%5D=$dbname&dbinfo%5Bdbuser%5D=$dbuser&dbinfo%5Bdbpw%5D=$dbpass&dbinfo%5Btablepre%5D=pre_&dbinfo%5Badminemail%5D=admin%40admin.com&dbinfo%5Bforceinstall%5D=1&admininfo%5Busername%5D=admin&admininfo%5Bpassword%5D=$passwd&admininfo%5Bpassword2%5D=$passwd&admininfo%5Bemail%5D=admin%40admin.com&submitname=%E4%B8%8B%E4%B8%80%E6%AD%A5"

rm -f $webroot/$root/data/install.lock
curl "$url" --data "$data"
