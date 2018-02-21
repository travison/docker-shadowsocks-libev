#!/bin/sh
set -e

exec ss-server -s $SERVER_ADDR \
               -p $SERVER_PORT \
               -k $PASSWORD \
               -m $METHOD \
               -t $TIMEOUT \
               -d $DNS_ADDR \
               -a $USER_EXEC \
               --plugin $PLUGIN \
               --plugin-opts $PLUGIN_OPTS \
               --fast-open \
               -u \
               --no-delay

ETH=$(eval "ifconfig | grep 'eth0'| wc -l")

if [[ "$SPEED" == '1' ]] && [[ "$ETH"  ==  '1' ]] ; then
	nohup /usr/local/bin/net_speeder eth0 "ip" >/dev/null 2>&1 &
else
  killall net_speeder &
fi

if [[ "$SPEED" == '1' ]] && [[ "$ETH"  ==  '0' ]] ; then
	nohup /usr/local/bin/net_speeder venet0 "ip" >/dev/null 2>&1 &
else
  killall net_speeder &
fi



