package org.example;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.io.Writable;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

import java.io.DataInput;
import java.io.DataOutput;
import java.io.IOException;
import java.util.*;

public class Main {
    static public class RecommendedWritable implements Writable {
         public Long user;
         public Long mutualFriend;

         public RecommendedWritable(Long user, Long mutualFriend) {
            this.user = user;
            this.mutualFriend = mutualFriend;
         }

         public RecommendedWritable() {
             this(-1L, -1L);
         }

         @Override
         public void write(DataOutput out) throws IOException {
             out.writeLong(user);
             out.writeLong(mutualFriend);
         }

         @Override
         public void readFields(DataInput in) throws IOException {
             user = in.readLong();
             mutualFriend = in.readLong();
         }

         @Override
         public String toString() {
             return " toUser: "
                + Long.toString(user) + " mutualFriend: "
                + Long.toString(mutualFriend);
         }
    }

    public static class FriendMapper extends Mapper<LongWritable, Text, LongWritable, RecommendedWritable> {

        @Override
        public void map(LongWritable key, Text value, Context context) throws IOException, InterruptedException {
            /** seperates the line into [user,friends] */
            String line[] = value.toString().split("\t");

            Long user = Long.parseLong(line[0]);

            if (line.length == 2) {
                String[] strFriends=line[1].split(",");
                ArrayList<String> friends = new ArrayList<>(Arrays.asList(strFriends));
                for(String friend:friends) {
                    /**
                     * emit user and friend as current friends
                     *  (user,recommendedFriend friend,-1)
                     *  -1 use to tell that they are already friends
                     */
                    context.write(
                            new LongWritable(user),
                            new RecommendedWritable(Long.parseLong(friend), -1L)
                    );
                }

                /**
                 * emit 2 friend who have the current user as commun friend
                 *   (recommended friend1,friend2,communfriend user)
                 */
                for (int i = 0; i < friends.size(); i++) {
                    for (int j = i + 1; j < friends.size(); j++) {
                        context.write(
                                new LongWritable(Long.parseLong(friends.get(i))),
                                new RecommendedWritable(Long.parseLong(friends.get(j)), user)
                        );
                        context.write(
                                new LongWritable(Long.parseLong(friends.get(j))),
                                new RecommendedWritable(Long.parseLong(friends.get(i)), user)
                        );
                    }
                }
            }
        }
    }

    public static class FriendReducer extends Reducer<LongWritable, RecommendedWritable, LongWritable, Text> {
        /** the key is the user we give recommendation to */
        @Override
        public void reduce(LongWritable key, Iterable<RecommendedWritable> values, Context context)
                throws IOException, InterruptedException {

            /** recommended friend, list of mutual friends */
            final Map<Long, List<Long>> mutualFriends = new HashMap<>();
            /**
             * a different map might recommend direct friends we dont want that
             *  ex: map1 -> (1,2,-1)  map2 -> (1,2,3)
             */
            Set<Long> directFriends = new HashSet<>();

            /** FriendCountWritable consist of the recommended friend-commun friend | isAlreadyFriend */
            for (RecommendedWritable val : values) {
                final Boolean isAlreadyFriend = (val.mutualFriend == -1);

                final Long toUser = val.user;
                final Long mutualFriend = val.mutualFriend;

                /** if a recommendedFriend has mutual friend -1 then already friends with user(key) */
                if (isAlreadyFriend) {
                    directFriends.add(toUser);
                } else {
                    if (mutualFriends.containsKey(toUser)) {
                        /** recommended friend: all related friends */
                        mutualFriends.get(toUser).add(mutualFriend);
                    } else {
                        /** first mutual friend then add new entry */
                        mutualFriends.put(toUser, new ArrayList<Long>() {{
                            add(mutualFriend);
                        }});
                    }
                }
            }

            /** maintains key in sorted order */
            SortedMap<Long, List<Long>> sortedMutualFriends = new TreeMap<>(new Comparator<Long>() {
                @Override
                public int compare(Long key1, Long key2) {
                    /**
                     * mutualFriends={
                     *     4:[1, 2, 3, 5]
                     *     3:[1, 2, 4, 5]
                     *     2:[1, 3, 4, 5]
                     *     5:[1, 2, 3]
                     *     1:[2, 3, 4]
                     *     6:[]
                     *  }
                     */
                    Integer v1 = mutualFriends.get(key1).size();
                    Integer v2 = mutualFriends.get(key2).size();
                    if (v1 > v2) {
                        return -1;
                    } else if (v1.equals(v2) && key1 < key2) {
                        return -1;
                    } else {
                        return 1;
                    }
                }
            });

            for (Map.Entry<Long, List<Long>> entry : mutualFriends.entrySet()) {
                /** remove all entry where a recommendedFriend:[communFriends]
                 *  is already friend with current user
                 */
                if (!directFriends.contains(entry.getKey())) {
                    sortedMutualFriends.put(entry.getKey(), entry.getValue());
                }
            }

            /** gets the top 10 with most commun friends */
            StringBuilder output = new StringBuilder();
            int count = 0;
            for (Map.Entry<Long, List<Long>> entry : sortedMutualFriends.entrySet()) {
                if (count >= 10) {
                    break;
                }
                if (count > 0) {
                    output.append(",");
                }
                output.append(entry.getKey());
                count++;
            }
            context.write(key, new Text(output.toString()));
        }
    }




    public static void main(String[] args) throws IOException, InterruptedException, ClassNotFoundException {
        Configuration configuration = new Configuration();
        Job job = Job.getInstance(configuration, "FriendRecommendation");

        job.setJarByClass(Main.class);
        job.setMapperClass(FriendMapper.class);
        job.setReducerClass(FriendReducer.class);

        job.setOutputKeyClass(LongWritable.class);
        job.setOutputValueClass(RecommendedWritable.class);

        FileInputFormat.addInputPath(job, new Path(args[0]));
        FileOutputFormat.setOutputPath(job, new Path(args[1]));

        System.exit(job.waitForCompletion(true) ? 0 : 1);
    }
}
