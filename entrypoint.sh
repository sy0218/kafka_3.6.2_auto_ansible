#!/bin/bash

system_file="/data/work/system_download.txt"
work_dir=$1
KAFKA_LOG_DIR=$(grep -i ".*log.dirs.*" "/data/work/system_download.txt" | awk -F '|' '{print $2}')
ip_array=($(grep kafka_ip ${system_file} | awk -F '|' '{for(i=2; i<=NF; i++) print $i}'))
len_ip_array=${#ip_array[@]}

setup_functions() {
    local setup_file_name=$1
    local remote_ip=$2

    # 원격 서버에서 실행할 명령어를 정의합니다.
    local command=$(cat <<EOF
    
setup_config=\$(awk "/\[${setup_file_name}-start\]/{flag=1; next} /\[${setup_file_name}-end\]/{flag=0} flag" ${system_file})
file_name=\$(find ${work_dir}/kafka/config -maxdepth 1 -type f -name $(echo $setup_file_name | awk -F ':' '{print $1}'))

while IFS= read -r setup_config_low; do
    env_name=\$(echo "\${setup_config_low}" | awk -F '|' '{print \$1}' | sed 's/[][]//g')
    env_value=\$(echo "\${setup_config_low}" | awk -F '|' '{print \$2}')
    if grep -q "\${env_name}" "\${file_name}"; then
        sed -i "s|[ #]*\${env_name}.*|\${env_name}\${env_value}|" "\${file_name}"
    else
        echo "\${env_name}\${env_value}" >> "\${file_name}"
    fi
done <<< "\${setup_config}"
EOF
    )

    # 원격 서버에서 명령어 실행
    ssh "${remote_ip}" "bash -s" <<< "$command"
}

setup_space_functions() {
    local setup_file_name=$1
    local remote_ip=$2

    # 원격 서버에서 실행할 명령어를 정의합니다.
    local command=$(cat <<EOF
setup_config=\$(awk "/\[${setup_file_name}-start\]/{flag=1; next} /\[${setup_file_name}-end\]/{flag=0} flag" ${system_file})
file_name=\$(find ${work_dir}/kafka/conf -type f -name ${setup_file_name})

while IFS= read -r setup_config_low; do
    env_name=\$(echo "\${setup_config_low}" | awk -F '|' '{print \$1}' | sed 's/[][]//g')
    env_value=\$(echo "\${setup_config_low}" | awk -F '|' '{print \$2}')
    if grep -q "\${env_name}" "\${file_name}"; then
        sed -i "s|[# ]*\${env_name}.*|\${env_name}     \${env_value}|" "\${file_name}"
    else
        echo "\${env_name}     \${env_value}" >> "\${file_name}"
    fi
done <<< "\${setup_config}"
EOF
    )

    # 원격 서버에서 명령어 실행
    ssh "${remote_ip}" "bash -s" <<< "$command"
}




for ((i=0; i<len_ip_array; i++)); do
        current_ip=${ip_array[$i]}
	ssh ${current_ip} "sed -i 's/\\\$(hostname)/$(ssh ${current_ip} hostname)/g' ${system_file}"
	# 브로커id 치환
	ssh ${current_ip} "sed -i 's/\\\$(broker_num)/$((i+1))/g' ${system_file}"
	setup_functions "server.properties" ${current_ip}
	ssh ${current_ip} "mkdir -p ${KAFKA_LOG_DIR} && chown -R $USER:$USER ${KAFKA_LOG_DIR}" # kafka 로그 디렉토리 생성

done
