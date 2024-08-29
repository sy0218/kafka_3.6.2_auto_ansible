#!/usr/bin/bash

system_file="/data/work/system_download.txt"

ip_array=($(cat ${system_file} | grep kafka_ip | awk -F '|' '{for(i=2; i<=NF; i++) print $i}'))
len_array=${#ip_array[@]}

ansible_dir=$1
tar_dir=$2

for ((i=0; i<len_array; i++));
do
        current_ip=${ip_array[$i]}
	scp ${ansible_dir}/kafka_*-?.?.?.tgz root@${current_ip}:${tar_dir}/
	# system_file 각 서버 배포
        scp ${system_file} root@${current_ip}:${system_file}
done
