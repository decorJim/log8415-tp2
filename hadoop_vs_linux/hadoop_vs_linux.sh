
# Setup the required configuration to run this script
./configuration.sh

# Create input directory in the Hadoop file system
hdfs dfs -mkdir input

# Copy the text we will use as an input into the Hadoop file system
hdfs dfs -copyFromLocal pg4300.txt input

# Pre-compiles WordCount source code to bytecode with the Hadoop tool
/usr/local/hadoop-3.3.4/bin/hadoop com.sun.tools.javac.Main WordCount.java

# Links the bytecode files into a .jar binary
jar cf wc.jar WordCount*.class

echo "Comparison between Linux command and Hadoop for counting word in Ulysses" >> hadoop_vs_linux_comparison.txt

# The following program executions are timed with the Linux time command.

# Use the previously pg4300.txt file located in the input directory in the Hadoop file system as an
# input to the WordCount program we just compiled
echo -e "\n\n----------Time for Hadoop----------" >> hadoop_vs_linux_comparison.txt
{ time (hadoop jar ./wc.jar WordCount ./input/ ./hadoop_output 2> /dev/null); } 2>> hadoop_vs_linux_comparison.txt


# The following command takes the text file as an input then convert all letters to lowercase,
# then removes all punctuation, then puts all the words in a single column in alphabetical order,
# then counts the occurence of every unique line, the formats it.	
echo -e "\n\n----------Time for Linux command----------" >> hadoop_vs_linux_comparison.txt
{ time cat pg4300.txt | tr 'A-Z' 'a-z' | tr -cd '[:alnum:]\n ' | tr ' ' '\n' | sort | uniq -c | awk '{print $2 "\t" $1}' > linux_command_output.txt; } 2>> hadoop_vs_linux_comparison.txt

