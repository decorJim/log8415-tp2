#!/bin/bash

# Setup the required configuration to run this script
./configuration.sh

# Looping over 9 texts to compute WordCount using Spark and store the execution times in hadoop_vs_spark_comparison.txt
echo -e '------------------- SPARK -------------------\n' >> hadoop_vs_spark_comparison.txt;
for file in $(ls ~/log8415-tp2/hadoop_vs_spark/Data)
  do
    filename="${file%.txt}";
    echo ------$filename------ >> hadoop_vs_spark_comparison.txt;
    echo ------Spark processing $file------;
# Timed WordCount Spark program    
{ time python3 -c "
import findspark
import shutil
import os
from pyspark.sql import SparkSession
session = SparkSession.builder.master('local').appName('WordCount').getOrCreate()
context = session.sparkContext
input_file = context.textFile(os.path.join(os.environ['HOME'], 'log8415-tp2/hadoop_vs_spark/Data', '${file}'))
nb_occurences_spark_output = input_file.flatMap(lambda line: line.split(' ')).map(lambda word: (word, 1)).reduceByKey(lambda x, y: x + y)
nb_occurences_spark_output.saveAsTextFile('./output/${filename}_nb_occurences_spark_output/')
context.stop()
session.stop()" 2>> spark.log; 
} 2>> spark.log |& grep -E 'real|user|sys'  >> hadoop_vs_spark_comparison.txt;
echo -e "\n\n" >> hadoop_vs_spark_comparison.txt;
done;

# Looping over 9 texts to compute WordCount using Hadoop and store the execution times in hadoop_vs_spark_comparison.txt
echo -e '\n\n\n------------------- HADOOP -------------------\n' >> hadoop_vs_spark_comparison.txt;
hdfs dfs -mkdir -p input;
for file in $(ls ~/log8415-tp2/hadoop_vs_spark/Data)
  do
    echo -----$file------ >> hadoop_vs_spark_comparison.txt;
    echo ------Hadoop processing $file------;
    hdfs dfs -copyFromLocal ~/log8415-tp2/hadoop_vs_spark/Data/$file input;
    # Timed WordCount Hadoop program
    { time hadoop jar ~/log8415-tp2/hadoop_vs_spark/wc.jar WordCount ./input/$file ./${file%.txt}_nb_occurences_hadoop_output/ 2> hadoop.log; } 2>> hadoop_vs_spark_comparison.txt;
    echo -e "\n\n" >> hadoop_vs_spark_comparison.txt;
  done;