#!/bin/bash

# Script to upgrade the installed jenkins plugings 

JENKINS_PLUGIN_MANAGER_VERSION=2.9.2
PLUGIN_MANAGER_DIRECTORY=/tmp/jenkins_plugin_manager
JENKINS_WAR_FILE_LOCATION=/usr/lib/jenkins/jenkins.war
JENKINS_PLUGIN_DIRECTORY=/var/lib/jenkins/plugins/

check_status () {
  if [ $? -ne 0 ]; then
    echo "Script Failed, Kindly check logs"
    exit 1
  fi
}

#Create directory for Jenkins plugin Manager
mkdir $PLUGIN_MANAGER_DIRECTORY

#check if required tools are present
for tool in wget java zip
do
  if ! command -v $tool &> /dev/null
  then
    yum install $tool -y
  fi
done

#Download Jenkins plugin Manager
wget https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/$JENKINS_PLUGIN_MANAGER_VERSION/jenkins-plugin-manager-$JENKINS_PLUGIN_MANAGER_VERSION.jar -P $PLUGIN_MANAGER_DIRECTORY
check_status

#Get list of Installed Plugins
ls -l /var/lib/jenkins/plugins | grep .jpi | awk '{print $9}' | cut -d "." -f 1 > /tmp/plugins.txt
check_status

#Download Jenkins Plugins
for PLUGIN in $(cat /tmp/plugins.txt)
do
  java -jar jenkins-plugin-manager-*.jar --war $JENKINS_WAR_FILE_LOCATION --plugins $PLUGIN -d $PLUGIN_MANAGER_DIRECTORY;
  check_status;
done

#Backup Jenkins Plugins Directory
zip -r /tmp/jenkins_plugins_`date +%s`.zip $JENKINS_PLUGIN_DIRECTORY/*
check_status

#copy the downloaded Jenkins plugins to Jenkins plugin Directory
##This Step requires sudo access
cp *.jpi $JENKINS_PLUGIN_DIRECTORY
chmod 644 /var/lib/jenkins/plugins/*.jpi
chown jenkins:jenkins /var/lib/jenkins/plugins/*.jpi
rm /tmp/plugins.txt
check_status