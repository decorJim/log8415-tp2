#!/bin/bash

# References:
# https://dzone.com/articles/getting-hadoop-and-running
# https://www.digitalocean.com/community/tutorials/how-to-install-java-with-apt-on-ubuntu-22-04

# Update package information and install JDK
sudo apt-get update && sudo apt-get install -y default-jdk && echo "JDK installed"

# Creates the JAVA_HOME env. variable which refers to the JDK installation directory
JAVA_HOME_DIR=$(dirname $(dirname $(readlink -f $(which java))))
echo "export JAVA_HOME=$JAVA_HOME_DIR" >> $HOME/.profile
source $HOME/.profile
echo "JAVA_HOME=$JAVA_HOME"

# Downloading and decompressing Hadoop in /usr/local/ if not already present
HADOOP_TAR="hadoop-3.3.4.tar.gz"
HADOOP_HOME="/usr/local/hadoop-3.3.4"
if [ ! -d "$HADOOP_HOME" ]; then
  wget "https://dlcdn.apache.org/hadoop/common/hadoop-3.3.4/$HADOOP_TAR"
  sudo tar -xf "$HADOOP_TAR" -C /usr/local/
else
  echo "HADOOP already installed"
fi

# Create HADOOP_HOME env. variable which refers to the installation directory of Hadoop
echo "export HADOOP_HOME=/usr/local/hadoop-3.3.4" >> $HOME/.profile
echo "export PATH=\$HADOOP_HOME/bin:\$PATH" >> $HOME/.profile
source $HOME/.profile
echo "HADOOP_HOME=$HADOOP_HOME"


# Adding env. variables to Hadoop env. script
HADOOP_ENV_SH="$HADOOP_HOME/etc/hadoop/hadoop-env.sh"
if [ -f "$HADOOP_ENV_SH" ]; then
  echo "export JAVA_HOME=$JAVA_HOME_DIR" | sudo tee -a "$HADOOP_ENV_SH" > /dev/null
  echo "export HADOOP_HOME=/usr/local/hadoop-3.3.4" | sudo tee -a "$HADOOP_ENV_SH" > /dev/null
else
    echo "Error: Hadoop environment file not found at $HADOOP_ENV_SH"
    exit 1
fi
