#!/bin/env bash
#
# apt update
if [ -f "/etc/debian_version" ]; then
  apt install git docker docker-compose npm nodejs nginx -y
else
  yum install git docker docker-compose npm nodejs nginx -y #install packages
fi
if [ $? != 0 ]; then
  echo "WARNING: Couldn't verify packages are upto date";
fi
CURRENT_DIRECTORY=`pwd`
SITE_LOC='/root/srv/site'
if [ ! -d $SITE_LOC ]; then #check if directory is created or not
  mkdir -p $SITE_LOC #creates directory
  if [ ! -d $SITE_LOC]; then
    echo "ERROR: You don't have permission to create folder $SITE_LOC";
    exit 100
  fi
fi
cd $SITE_LOC
package1='frogtoberfest'
GITHUB_LINK='https://github.com/ragas21/frogtoberfest.git'
if [ ! -d $package1 ]; then
  git clone $GITHUB_LINK -o $package1
  cd $package1
else
  cd $package1
  git pull
  if [ $? != 0 ]; then
    cd ..
    git clone $GITHUB_LINK -o $package1
    if [ ! -d $package1 ]; then
      echo "ERROR: couldnt clone $package1"
      exit 102
    else
      cd $package1
    fi
  fi
fi

TOKEN="8204c242e532c8db05cd224c0185d428b5644dbe"
tail -n 9 ./.env.example > ./.env
echo -e "\nREACT_APP_GITHUB_TOKEN=$TOKEN" >> ./.env

systemctl is-active --quiet nginx || systemctl start nginx
if [ $? != 0 ]; then
  echo "Error: couldn't start nginx"
  exit 103
fi
NGINX_PATH='/etc/nginx'
if [ ! -d $NGINX_PATH ]; then
  mkdir $NGINX_PATH
  if [ ! -d $NGINX_PATH ]; then
    echo "ERROR: cannot create $NGINX_PATH"
    return 100
  fi
fi
if [ ! -d $NGINX_PATH/sites-enabled ]; then
  mkdir $NGINX_PATH/sites-enabled
fi
if [ ! -d $NGINX_PATH/sites-available ]; then
  mkdir $NGINX_PATH/sites-available
fi

CONF_BASE_DIR="$CURRENT_DIRECTORY"
cp $CONF_BASE_DIR/app.local.conf $CONF_BASE_DIR/app1.local.conf $NGINX_PATH/sites-available
ln -s $NGINX_PATH/sites-available/app.local.conf $NGINX_PATH/sites-enabled/app.local.conf
ln -s $NGINX_PATH/sites-available/app1.local.conf $NGINX_PATH/sites-enabled/app1.local.conf

#install yarn
cd $CURRENT_DIRECTORY
mkdir yarn
if [ ! -d ./yarn ]; then
  echo "ERROR: couldn't create directory yarn "
  return 100
fi
#npm i react-scripts
cd ./yarn
npm install -g yarn
npx create-react-app my-app
cd my-app
rm -rf node_modules
yarn install

cd $SITE_LOC/$package1
yarn
#yarn start

#docker start
systemctl is-active --quiet docker || systemctl start docker
if [ $? != 0 ]; then
  echo "DOCKER cannot be started"
  exit 104
fi

docker-compose up --build

echo "SUCCESSFUL HERE"
exit 0
