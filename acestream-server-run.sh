#!/bin/bash
USER=$USER
HER=$(dirname $(readlink -f "${0}"))
ACE_VERSION=`cat $HER/VERSION`
TOKEN=mytoken
PORT=6701
HTTP_PORT=6878

mkdir -p /home/$USER/.ACEStream/

"${HER}"/Build/$ACE_VERSION/AceStream-"$ACE_VERSION".AppImage @$HER/engine.conf &

echo "Сервер доступен локально по адресу: http://localhost:$HTTP_PORT/webui/app/$TOKEN/server#proxy-server-main"
sleep 3
/usr/bin/google-chrome-stable http://localhost:$HTTP_PORT/webui/app/$TOKEN/server#proxy-server-main || /usr/bin/firefox http://localhost:$HTTP_PORT/webui/app/$TOKEN/server#proxy-server-main &
