#!/bin/bash

# Update package list and upgrade all packages
sudo apt-get update && sudo apt-get upgrade -y

# Installation of Spark dependencies
sudo apt install python3-pip -y && pip install pyspark findspark && echo "pip, pyspark and findspark installed";;

# Install JDK
sudo apt-get install -y default-jdk && echo "JDK installed"

# Creating the JAVA_HOME env. variable which refers to the JDK installation directory
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

# Creating HADOOP_HOME env. variable which refers to the installation directory of Hadoop
echo "export HADOOP_HOME=$HADOOP_HOME" >> $HOME/.profile
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

# Compiling JAR executable from WordCount.java 
hadoop com.sun.tools.javac.Main WordCount.java;
jar cf wc.jar WordCount*.class;
