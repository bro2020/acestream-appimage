#!/bin/bash
USER=$USER
HER=$(dirname $(readlink -f "${0}"))
WD=$(whereis docker)
ACE_VERSION=`cat $HER/VERSION`
BUILD_TIME=$(date +%d_%m_%Y-%H_%M)
COMMAND="apt-get update && \
apt-get install git fuse curl wget file binutils glib-2.0.0 -y && \
cd opt/ && \
git clone https://github.com/bro2020/acestream-appimage.git && \
cd acestream-appimage/ && \
ACE_VERSION=\"$ACE_VERSION\" USER=$USER ./pkg2appimage.appimage recipes/acestream.yml"
if [ -z "$WD" ];
then 
echo '### Docker not installed! Canceled ###'
exit 1
else
echo ' ### Docker installed, startind make build... ###'
mkdir -p "${HER}"/build/${ACE_VERSION}-${BUILD_TIME} && \
mkdir -p "${HER}"/tmp && \
rm -rf "${HER}"/tmp/* && \
docker run -i --name builder-appimage -e ACE_VERSION=$ACE_VERSION -e USER=$USER --privileged -v "${HER}"/tmp:/opt/ debian:9-slim /bin/bash -c "$COMMAND" && \
docker rm builder-appimage && \
docker rmi debian:9-slim && \
sudo mv "${HER}"/tmp/acestream-appimage/out/* "${HER}"/build/${ACE_VERSION}-${BUILD_TIME}/AceStream-"$ACE_VERSION".AppImage && \
cp "${HER}"/acestream.conf "${HER}"/build/${ACE_VERSION}-${BUILD_TIME}/ && \
sudo rm -rf "${HER}"/tmp && \
sudo chown -R $USER:$USER "${HER}"/build/${ACE_VERSION}-${BUILD_TIME}/* && \
echo "### build Completed! AppImage file in directory build/${ACE_VERSION}-${BUILD_TIME}/AceStream-$ACE_VERSION.AppImage ###" && \
exit 0 || docker rm builder-appimage; \
docker rmi debian:9-slim; sudo rm -rf "${HER}"/tmp; echo '### Error! Canceled! ###'; exit 1
fi
