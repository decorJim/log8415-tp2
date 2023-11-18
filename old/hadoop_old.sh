#!/bin/bash

# update package information for ubuntu system
sudo apt-get update
# install default jdk on system
sudo apt install -y default-jdk

# save java path variable in script file .bash_login
sudo echo "export JAVA_HOME=/usr/bin/java" >> /home/ubuntu/.bash_login

# download hadoop
sudo wget https://dlcdn.apache.org/hadoop/common/hadoop-3.3.6/hadoop-3.3.6-src.tar.gz

# extract the content in /usr/local/ path for manual software installation 
sudo tar -xf hadoop-3.3.6-src.tar.gz -C /usr/local/

# add hadoop environment variable to script file .bash_login
sudo echo "export HADOOP_HOME=/usr/local/hadoop-3.3.6-src" >> /home/ubuntu/.bash_login

# set path variable with hadoop
sudo echo "export PATH=\$HADOOP_HOME/bin:\$PATH" >> /home/ubuntu/.bash_login

# activate the script
source "/home/ubuntu/.bash_login"

# Configuring Environment of Hadoop Daemons
echo "export JAVA_HOME=/usr/bin/java" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh
echo "export HADOOP_HOME=/usr/local/hadoop-3.3.6-src" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh














