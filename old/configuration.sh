#!/bin/bash

# Installation of Spark dependencies

sudo apt-get update && sudo apt-get upgrade -y

apt install python3-pip -y;
pip install pyspark;
pip install findspark;
echo "pyspark and findspark installed"

mkdir /var/lib/hadoop;
chmod 777 /var/lib/hadoop;
