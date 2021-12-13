#!/bin/bash
USER=$USER
HER=$(dirname $(readlink -f "${0}"))
ACE_VERSION=`cat VERSION`
TOKEN=mytoken
PORT=6701
HTTP_PORT=6878

mkdir -p /home/$USER/.ACEStream/

"${HER}"/Build/$ACE_VERSION/AceStream-"$ACE_VERSION".AppImage --client-console --host 127.0.0.1 --port $PORT --http-port $HTTP_PORT --access-token $TOKEN --service-access-token $USER --stats-report-peers --live-buffer 35 --vod-buffer 80 --max-connections 500 --vod-drop-max-age 120 --max-peers 100 --max-upload-slots 20 --download-limit 0 --stats-report-interval 2 --slots-manager-use-cpu-limit 1 --core-dlr-periodic-check-interval 5 --check-live-pos-interval 5 --refill-buffer-interval 1 --core-skip-have-before-playback-pos 1 --webrtc-allow-outgoing-connections 1 --upload-limit 100 --cache-dir /tmp/.ACEStream --state-dir /tmp/.ACEStream --log-file /home/$USER/.ACEStream/acestream.log --log-debug 0 &

echo "Сервер доступен локально по адресу: http://localhost:$HTTP_PORT/webui/app/$TOKEN/server#proxy-server-main"
sleep 3
/usr/bin/google-chrome-stable http://localhost:$HTTP_PORT/webui/app/$TOKEN/server#proxy-server-main & || /usr/bin/firefox http://localhost:$HTTP_PORT/webui/app/$TOKEN/server#proxy-server-main &
