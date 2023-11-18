# Setup the required configuration to run this script
./configuration.sh

hdfs dfs -mkdir input

# Copy the text we will use as an input into the Hadoop file system
hdfs dfs -copyFromLocal data.txt input

# Pre-compiles WordCount source code to bytecode with the Hadoop tool
/usr/local/hadoop-3.3.4/bin/hadoop com.sun.tools.javac.Main Main.java

# Links the bytecode files into a .jar binary
jar cf main.jar Main*.class

# Run friend suggestion algorithm
hadoop jar ./main.jar Main ./input/ ./output 2> friend_suggestion.log
