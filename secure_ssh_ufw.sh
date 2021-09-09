#!/bin/bash

strCurrDir=$(cd `dirname $0`; pwd)
strPath_IP_Blacklist=${strCurrDir}"/IP_Blacklist.txt"
if [ ! -f ${strPath_IP_Blacklist} ]; then
    touch ${strPath_IP_Blacklist}
fi

strLogPath=""
if [ -f "/var/log/auth.log" ]; then
    strLogPath="/var/log/auth.log"
elif [ -f "/var/log/secure" ]; then
    strLogPath="/var/log/secure"
fi

if [ ${#strLogPath} -eq 0 ]; then
    echo "log file does not exist."
    exit
fi

IP_List=$(cat ${strLogPath} | grep "$(date +%b) $(date +%_d) $(date +%H):" | grep 'Failed password' | awk '{print $(NF-3)}' | sort | uniq -c | awk '{print $2"="$1}')
IP_List=${IP_List}" "$(cat ${strLogPath} | grep "$(date +%b) $(date +%_d) $(date +%H):" | grep 'Connection closed by' | awk '{print $(NF-3)}' | sort | uniq -c | awk '{print $2"="$1}')
#IP_List=$(cat ${strLogPath} | grep "$(date +%b) 30 19:" | grep 'Failed password' | awk '{print $(NF-3)}' | sort | uniq -c | awk '{print $2"="$1}')

#Add IP
echo ${IP_List} | sed 's/ /\n/g' | while read line
do
    if [ ${#line} -gt 0 ]; then
        strIP=$(echo ${line} | awk -F '=' '{print $1}')
        strCount=$(echo ${line} | awk -F '=' '{print $2}')
        if [ ${strCount} -ge 10 ]; then
            if [ `grep -c "$(echo ${strIP})" "${strPath_IP_Blacklist}"` -eq '0' ]; then
                strDelTime=$(date +'%Y-%m-%d %H:%M:%S' --date="+7 day")
                echo ${strDelTime}","${strIP}","${strCount} >> ${strPath_IP_Blacklist}
                if echo ${strIP} | grep -E "^(([1-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([1-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$" >>/dev/null 2>&1; then
                    sudo ufw insert 1 deny from ${strIP} to any comment "From: secure_ssh.sh | Remove after: ${strDelTime}"
                else
                    numbered=$(sudo ufw status numbered | grep -F ' (v6)' | head -1 | sed -e 's/\[\([0-9]*\)\].*/\1/')
                    sudo ufw insert ${numbered} deny from ${strIP} to any comment "From: secure_ssh.sh | Remove after: ${strDelTime}"
                fi
            fi
        fi
    fi
done
#Add IP

#Delete IP
cat ${strPath_IP_Blacklist} | while read line
do
    if [ ${#line} -gt 0 ]; then
        strDateTime=$(echo ${line} | awk -F ',' '{print $1}')
        strIP=$(echo ${line} | awk -F ',' '{print $2}')
        strCount=$(echo ${line} | awk -F ',' '{print $3}')
        if [ `date -d "$(date +'%Y-%m-%d %H:%M:%S')" +%s` -gt `date -d "$strDateTime" +%s` ]; then
            sed -i "/${strIP}/d" ${strPath_IP_Blacklist}
            sudo ufw delete deny from ${strIP}
        fi
    fi
done
#Delete IP
