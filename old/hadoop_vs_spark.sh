#!/bin/bash

# Setup the required configuration for the hadoop_vs_spark.sh ro run

./configuration.sh

# Update package information and install JDK

sudo apt-get update && sudo apt-get install -y default-jdk

echo "JDK installed"

# Creating the JAVA_HOME env. variable which refers to the JDK installation directory

JAVA_HOME_DIR=$(dirname $(dirname $(readlink -f $(which java))))

echo "export JAVA_HOME=$JAVA_HOME_DIR" >> $HOME/.profile

source $HOME/.profile

echo "JAVA_HOME=$JAVA_HOME"


# Downloading and decompressing Hadoop in /usr/local/ if not already present

HADOOP_TAR="hadoop-3.3.4.tar.gz"

if [ ! -f "$HADOOP_TAR" ]; then

    wget "https://dlcdn.apache.org/hadoop/common/hadoop-3.3.4/$HADOOP_TAR"

    sudo tar -xf "$HADOOP_TAR" -C /usr/local/

else

    echo "HADOOP already installed"

fi

# Creating HADOOP_HOME env. variable which refers to the installation directory of Hadoop

echo "export HADOOP_HOME=/usr/local/hadoop-3.3.4" >> $HOME/.profile

echo "export PATH=\$HADOOP_HOME/bin:\$PATH" >> $HOME/.profile

source $HOME/.profile

echo "HADOOP_HOME=$HADOOP_HOME"

# Adding env. variables to Hadoop env. script

HADOOP_ENV_SH="$HADOOP_HOME/etc/hadoop/hadoop-env.sh"

if [ -f "$HADOOP_ENV_SH" ]; then

    echo "export JAVA_HOME=$JAVA_HOME_DIR" >> "$HADOOP_ENV_SH"

    echo "export HADOOP_HOME=/usr/local/hadoop-3.3.4" >> "$HADOOP_ENV_SH"

else

    echo "Error: Hadoop environment file not found at $HADOOP_ENV_SH"

    exit 1

fi

# Configuration of Hadoop Distributed File System (HDFS) 

hdfs namenode -format;

touch ~/start;

echo "export HDFS_NAMENODE_USER=\"root\""  >>  ~/.profile;

echo "export HDFS_DATANODE_USER=\"root\""  >>  ~/.profile;

echo "export HDFS_SECONDARYNAMENODE_USER=\"root\""  >>  ~/.profile;

echo "export YARN_RESOURCEMANAGER_USER=\"root\""  >>  ~/.profile;

echo "export YARN_NODEMANAGER_USER=\"root\""  >>  ~/.profile;


source ~/.profile;

$HADOOP_HOME/sbin/start-dfs.sh;

hdfs dfs -mkdir -p ~/log8415-tp2/input;

hdfs dfs -mkdir -p ~/log8415-tp2/sn_input;

# Compiling and Creating JAR file for the WordCount.java 

hadoop com.sun.tools.javac.Main wordcount/WordCount.java;

cd wordcount;

jar cf wc.jar WordCount*.class;

# Compiling and Creating JAR file for the Social Network Java files

cd ..;

# Computing WordCount using Spark on the datasets contained in ~/Data/ and store the execution times in hadoop_vs_spark_comparaison.txt.

echo 'SPARK -------------------' >> hadoop_vs_spark_comparaison.txt;


for file in $(ls ~/log8415-tp2/Data)

do


  filename=$(echo $file| cut  -d'.' -f 1);

  echo -n $filename >> hadoop_vs_spark_comparaison.txt;

  { time python3 -c "

import findspark

import shutil

import os

from pyspark.sql import SparkSession

spark = SparkSession.builder.master('local').appName('FirstProgram').getOrCreate()

sc=spark.sparkContext

text_file = sc.textFile('Data/${file}')

counts = text_file.flatMap(lambda line: line.split(' ')).map(lambda word: (word, 1)).reduceByKey(lambda x, y: x + y)

if os.path.exists('output/${filename}_spark_res/'):

  shutil.rmtree('output/${filename}_spark_res/')

counts.saveAsTextFile('output/${filename}_spark_res/')

sc.stop()

spark.stop()"

2>1; } 2>> hadoop_vs_spark_comparaison.txt;

  echo "" >> hadoop_vs_spark_comparaison.txt;

done;

echo "" >> hadoop_vs_spark_comparaison.txt;

echo "" >> hadoop_vs_spark_comparaison.txt;

# Computing WordCount using Hadoop on the datasets contained in ~/Data/ and store the execution times in hadoop_vs_spark_comparaison.

echo 'HADOOP -------------------' >> hadoop_vs_spark_comparaison.txt;


for file in $(ls ~/log8415-tp2/Data)

do

  echo -n $file >> hadoop_vs_spark_comparaison.txt;

  hadoop fs -rm -r ~/log8415-tp2/input/;

  hadoop fs -rm -r ~/log8415-tp2/output_$file/;

  hdfs dfs -mkdir -p ~/log8415-tp2/input;

  hadoop fs -cp ~/log8415-tp2/Data/$file ~/log8415-tp2/input/;

  { time hadoop jar ~/log8415-tp2/wordcount/wc.jar WordCount ~/log8415-tp2/input/ ~/log8415-tp2/output_$file 2>1; } 2>> hadoop_vs_spark_comparaison.txt;

  echo "" >> hadoop_vs_spark_comparaison.txt;

done;

source ~/.profile;