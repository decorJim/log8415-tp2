# log8415-tp2

Our team's repository for the TP2: https://github.com/decorJim/log8415-tp2

Instruction to run the code

1. To seamlessly navigate through the AWS setup and execute the log8415-tp2 scripts, follow these steps: Begin by updating the ~/.aws/credentials file with your AWS credentials.
2. Next, clone the project repository from https://github.com/decorJim/log8415-tp2.git onto your local machine.
3. Move into the log8415-tp2/infra/ directory and initialize Terraform with terraform init, followed by applying it using terraform apply.
4. Once the instance is created in your AWS account, connect to it as a root user.
5. Inside the instance, clone the same project repository or use scp to secure copy the project from your local machine to the instance.
6. The following sections explain how to run the code for the 3 experiments which are Hadoop vs Linux, Hadoop vs Spark and Friend suggestions

Hadoop vs. Linux

1. To execute the Hadoop vs Linux experiment, navigate to the log8415-tp2/hadoop_vs_linux/ directory and ensure executables permissions by running sudo chmod +x configuration.sh and sudo chmod +x hadoop_vs_linux.sh.
2. After, run the hadoop_vs_linux.sh script.
3. The previous command should output a file named hadoop_vs_linux_comparison.txt which contain the chrono time for each execution. Also, you can find in this same directory the output of the two algorithms which are the lists of words with their number of occurrences.

Hadoop vs. Spark

1. To execute the Hadoop vs Linux experiment, navigate to the log8415-tp2/hadoop_vs_spark/ directory and ensure executables permissions by running sudo chmod +x configuration.sh and sudo chmod +x hadoop_vs_spark.sh.
2. After, run the hadoop_vs_spark.sh script and follow the prompts displayed on the screen, checking all options and pressing 'enter'.
3. The previous commands should output a file named hadoop_vs_spark_comparison.txt which contain the chrono time for each execution. Also, you can find in this same directory the output of the two algorithms which are the lists of words with their number of occurrences.

Friend suggestions

1. To execute the Friend suggestions experiment, navigate to the log8415-tp2/friend_suggestions/ directory and ensure executables permissions by running sudo chmod +x configuration.sh and sudo chmod +x friend_suggestions.sh.
2. After, run the friend_suggetions.sh script.
3. The previous commands should output a directory called ouput which contain the results of the algorithm which are the friend suggestions.

# References used in the project

https://dzone.com/articles/getting-hadoop-and-running
https://hadoop.apache.org/docs/stable/hadoop-mapreduce-client/hadoop-mapreduce-client-core/MapReduceTutorial.html
https://www.digitalocean.com/community/tutorials/how-to-install-java-with-apt-on-ubuntu-22-04
https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/SingleCluster.html

# Reference to the MapReduce code for friend suggestion

- reference: https://stackoverflow.com/questions/15035778/hadoop-m-r-to-implement-people-you-might-know-friendship-recommendation
