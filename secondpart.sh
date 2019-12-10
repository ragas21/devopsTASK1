#!/usr/bin/env bash
#
if [ -f "/etc/debian_version" ]; then
  apt install git docker docker-compose npm nodejs nginx -y
else
  yum install git docker docker-compose npm nodejs nginx -y #install packages
fi
CURRENT_DIRECTORY=`pwd`
SITE_LOC='/root/srv/site'
#NGINX start
systemctl is-active --quiet nginx || systemctl start nginx
if [ $? != 0 ]; then
  echo "Error: couldn't start nginx"
  exit 103
fi

if [ ! -d $SITE_LOC ]; then
  mkdir -p $SITE_LOC
fi
if [ $? != 0 ]; then
  echo "Could not create directory $SITE_LOC"
  exit 100
fi
GITHUB_LINK='https://github.com/mesaugat/express-api-es6-starter.git'
cd $SITE_LOC
package2='express-api-es6-starter'
if [ ! -d $package2 ]; then
  git clone $GITHUB_LINK -o $package2
fi
if [ ! -d $package2 ]; then
  echo "ERROR: Git clone didnt work"
  exit 101
fi
cd $package2
cp ./.env.example ./.env
rm -rf .git

#docker start
systemctl is-active --quiet docker || systemctl start docker
if [ $? != 0 ]; then
  echo "DOCKER cannot be started"
  exit 104
fi

docker-compose up

echo "SUCCESSFUL"
exit 0
