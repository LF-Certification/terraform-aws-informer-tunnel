#!/bin/bash
if [[ ! -z "${PUBKEY}" ]]; then
  echo $PUBKEY >bifrost.pub
  chmod 600 bifrost.pub
fi
if [[ ! -z "${PRIVKEY}" ]]; then
  echo "$PRIVKEY" >bifrost
  chmod 600 bifrost
fi
if [[ ! -z "${CERT}" ]]; then
  echo $CERT >bifrost-cert.pub
  chmod 600 bifrost-cert.pub
fi
echo "--------------PUBLIC KEY--------------"
cat bifrost.pub
echo "------------END PUBLIC KEY------------"
ssh -v -o ServerAliveInterval=60 -o StrictHostKeyChecking=accept-new -i bifrost -R 172.31.86.235:$HUB_PORT:$DEST_SERVER:$DEST_PORT -N datahub@datahub.informer.cloud
