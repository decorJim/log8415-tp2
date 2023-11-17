#!/bin/bash

# Installation of Spark dependencies

sudo apt-get update && sudo apt-get upgrade -y

apt install python3-pip -y;
pip install pyspark;
pip install findspark;
echo "pyspark and findspark installed"

# SSH setup
apt install -y ssh;

service ssh restart;

ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa;
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys;
chmod 0600 ~/.ssh/authorized_keys;

mkdir /var/lib/hadoop;
chmod 777 /var/lib/hadoop;