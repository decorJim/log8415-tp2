sudo rm WordCount*.class wc.jar results.txt linux_wc_output.txt
hdfs dfs -rm -r ./hadoop_wc_output
hdfs dfs -rm -r ./input
