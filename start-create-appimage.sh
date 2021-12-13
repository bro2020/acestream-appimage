#!/bin/bash
USER=$USER
HER=$(dirname $(readlink -f "${0}"))
WD=$(whereis docker)
APPVERSION=`cat VERSION`
COMMAND="apt-get update && \
apt-get install git fuse curl wget file binutils glib-2.0.0 -y && \
cd opt/ && \
git clone https://github.com/bro2020/acestream-appimage.git && \
cd acestream-appimage/ && \
APPVERSION=\"$APPVERSION\" ./pkg2appimage.appimage recipes/acestream.yml"
if [ -z "$WD" ];
then 
echo '### Docker not installed! Canceled ###'
exit 1
else
echo ' ### Docker installed, startind make build... ###'
mkdir -p "${HER}"/Build/$APPVERSION && \
rm -rf "${HER}"/Build/$APPVERSION/* && \
docker run -i --name builder-appimage -e APPVERSION=$APPVERSION --privileged -v "${HER}"/Build/$APPVERSION:/opt/ debian:9-slim /bin/bash -c "$COMMAND" && \
docker rm builder-appimage && \
docker rmi debian:9-slim && \
sudo mv "${HER}"/Build/$APPVERSION/acestream-appimage/out/* "${HER}"/Build/$APPVERSION && \
sudo rm -rf "${HER}"/Build/$APPVERSION/acestream-appimage/ && \
sudo chown -R $USER:$USER "${HER}"/Build/$APPVERSION/ && \
echo "### Build Completed! AppImage file in directory Build/\"$APPVERSION\" ###"
# || \
#docker rm builder-appimage; docker rmi debian:9-slim; sudo rm -rf "${HER}"/Build/; echo '### Error! Canceled! ###'
fi
