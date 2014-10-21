#!/bin/bash
localpath=$(cd "$(dirname "$0")";pwd)
activemq=$localpath/apache-activemq-5.9.0
karaf_path=$localpath/karaf_proxy
mqAgent=$karaf_path/mqAgent.properties
mqServer=$karaf_path/mqServer.properties
mkdir -p $activemq/download/documents
mkdir -p $activemq/download/commandResult
echo -n "[Enter Server ip:];"
         read ARGV1
echo -n "[Enter Proxy ip:];"
         read ARGV2

if [ "x$ARGV1" = "x" -a "x$ARGV2" = "x" ] ; then
        echo "Please Enter Params!!"
        exit
fi

echo "client.mq.url=failover:(tcp://$ARGV1:10052)?jms.blobTransferPolicy.defaultUploadUrl=http://$ARGV1:10054/fileserver/" > $mqAgent
echo "client.mq.username=admin" >> $mqAgent
echo "client.mq.password=admin" >> $mqAgent
echo "client.mq.ip=$ARGV2" >> $mqAgent
echo "client.mq.proxy=0" >> $mqAgent
echo "synchronization.frequency=*/5 * * * *" >> $mqAgent
echo "client.mq.synctime=*/3 * * * *" >> $mqAgent

echo "mq.url=failover:(tcp://$ARGV2:10052)?jms.blobTransferPolicy.defaultUploadUrl=http://$ARGV2:10054/fileserver/," >> $mqServer
echo "mq.ip=$ARGV2"  >> $mqServer
echo "mq.username=admin" >> $mqServer
echo "mq.password=admin" >> $mqServer
echo "mysql.url=" >> $mqServer
echo "mysql.user=" >> $mqServer
echo "Synchronization.type=2,3" >> $mqServer
echo "mq.synctime=*/3 * * * *" >> $mqServer
echo "file.savepath=$activemq/download/" >> $mqServer
echo "document.savepath=$activemq/download/documents" >> $mqServer
echo "commandResult.savepath=$activemq/download/commandResult" >> $mqServer

chmod -R 755 $karaf_path
chmod -R 755 $activemq

#judge 10052 portal 
oldfileserver=`ps -ef|grep -v grep|grep FileServer`
snc_con=`ps -ef|grep -v grep|grep snc_container_agent.jar`
if [ "$oldfileserver" = "" ] ; then
    echo ""
else
    kill -9 `ps -ef|grep -v grep|grep FileServer|awk '{print $2}'`
fi
if [ "$snc_con" = "" ] ; then
    echo ""
else
    kill -9 `ps -ef|grep -v grep|grep snc_container_agent|awk '{print $2}'`
fi

#start mq
export JAVA_HOME=$karaf_path/jdk

$activemq/bin/activemq start 2>&1 >> /dev/null

sleep 5s
#start karaf
cd $karaf_path/bin
./start clean 2>&1 >> /dev/null
sleep 2s
status=`ps -ef|grep -v grep|grep karaf`
if [ "$status" = "" ] ; then
    echo "Install Faild"
else
    echo "Install Completed"
fi


