#!/bin/bash
## Created By.Farid Arjmand ##

###############################
########## Functions ##########
###############################

JSON ()
{
        echo -e "{\n\t\"data\":[\n"
        for PID in `ps -ef | pgrep "redis"`;do
                ADDRESS=$(lsof -p $PID | awk '/cwd/{print $NF}')
                PORT=$(echo info | $ADDRESS/redis-cli | awk -F":" '/tcp_port/{print $2}' | dos2unix)
                NAME=$(echo $ADDRESS | awk -F"/" '{print $NF}')
                if [ -z $PORT ];then
                        PORT=$(lsof -p $PID | awk '/LISTEN/{print $(NF-1)}' | awk -F":" '{print $2}')
                fi
                for j in `/usr/sbin/ifconfig -a | awk '/inet/{print $2}'`;do
                        if [ `$ADDRESS/redis-cli -h $j -p $PORT ping` == "PONG" ];then
                                IP=$j
                        fi
                done
                echo -e "\t {\n\t  \"{#REDIS}\":\"$ADDRESS\","
                echo -e "\t  \"{#NAME}\":\"$NAME\","
                echo -e "\t  \"{#PORT}\":\"$PORT\","
                echo -e "\t  \"{#PID}\":\"$PID\","
                echo -e "\t  \"{#IP}\":\"$IP\" \n\t },"
        done
        echo -e "\n\t { \"{#END}\":\"END\" }\n\n\t]\n}"
}

##############################
############ Main ############
##############################

case $1 in
        ping)if [ `$2/redis-cli -h $3 -p $4 ping` == "PONG" ];then echo "UP"; else echo "DOWN"; fi 2>/dev/null;;
        reload)JSON > $HOME/REDIS.tmp 2>/dev/null && echo OK;;
        db)$2/redis-cli -h $3 -p $4 info | grep -c ^db 2>/dev/null;;
        size)$2/redis-cli -h $3 -p $4 dbsize | awk '{print $NF}';;
        status)$2/redis-cli -h $3 -p $4 info | gawk -F":" -v SEARCH="$5" 'match($0, SEARCH) {print $2}';;
        *)cat $HOME/REDIS.tmp
esac

##############################
############ END #############
##############################
