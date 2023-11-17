package org.example;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

import java.io.IOException;

public class Main {
    /** input keyType, input value type, output key type, output value type */
    public static class FriendMapper extends Mapper<LongWritable, Text, Text, IntWritable> {

        @Override
        public void map(LongWritable key, Text line, Context context) throws IOException, InterruptedException {
            System.out.println(line);
            /** convert and put into array [user,friends] */
            String strLine[]=line.toString().split("\t");
            /** extracts user */
            int user=Integer.valueOf(strLine[0]);
            /** extracts friends */
            String friends[]=strLine[1].split(",");

            /** idea is that all friend in array is considered to have mutual friend (current user)
             *  [2,3,4,5,6]
             *  (2,3) (3,2) (2,4) (4,2) (2,5) ....
             *  map relation with count of 1
             *
             */

            for(int i=0;i<friends.length;i++) {
                for(int j=0;j<friends.length;j++) {
                    if(friends[i]!=friends[j]) {
                        Text commonFriendPair = new Text();
                        commonFriendPair.set(friends[i]+","+friends[j]);
                        context.write(commonFriendPair,new IntWritable(1));
                    }
                }
            }

        }
    }

    public static class FriendReducer extends Reducer<Text, IntWritable, Text, IntWritable> {

        @Override
        public void reduce(Text key,Iterable<IntWritable> values,Context context) throws IOException, InterruptedException {
            int sum=0;
            for(IntWritable value:values) {
                sum+=value.get();
            }
            context.write(key,new IntWritable(sum));
        }

    }

    public static void main(String[] args) throws IOException, InterruptedException, ClassNotFoundException {

        Configuration configuration = new Configuration();

        /** creates a new job **/
        Job job = Job.getInstance(configuration, "FriendRecommendation");

        job.setJarByClass(Main.class);
        job.setMapperClass(FriendMapper.class);
        //job.setCombinerClass(FriendReducer.class);
        job.setReducerClass(FriendReducer.class);
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(IntWritable.class);

        FileInputFormat.addInputPath(job, new Path(args[0]));
        FileOutputFormat.setOutputPath(job, new Path(args[1]));
        System.exit(job.waitForCompletion(true) ? 0 : 1);

    }
}