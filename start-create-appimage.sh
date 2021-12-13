#!/bin/bash
USER=$USER
HER=$(dirname $(readlink -f "${0}"))
WD=$(whereis docker)
ACE_VERSION=`cat VERSION`
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
mkdir -p "${HER}"/Build/$ACE_VERSION && \
rm -rf "${HER}"/Build/$ACE_VERSION/* && \
docker run -i --name builder-appimage -e ACE_VERSION=$ACE_VERSION -e USER=$USER --privileged -v "${HER}"/Build/$ACE_VERSION:/opt/ debian:9-slim /bin/bash -c "$COMMAND" && \
docker rm builder-appimage && \
docker rmi debian:9-slim && \
sudo mv "${HER}"/Build/$ACE_VERSION/acestream-appimage/out/* "${HER}"/Build/$ACE_VERSION/AceStream-"$ACE_VERSION".AppImage && \
sudo rm -rf "${HER}"/Build/$ACE_VERSION/acestream-appimage/ && \
sudo chown -R $USER:$USER "${HER}"/Build/$ACE_VERSION/ && \
echo "### Build Completed! AppImage file in directory Build/$ACE_VERSION/AceStream-$ACE_VERSION.AppImage ###" && \
exit 0 || docker rm builder-appimage; \
docker rmi debian:9-slim; sudo rm -rf "${HER}"/Build/; echo '### Error! Canceled! ###'; exit 1
fi
