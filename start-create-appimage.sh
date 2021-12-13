#!/bin/bash
USER=$USER
HER=$(dirname $(readlink -f "${0}"))
WD=$(whereis docker)
if [ -z "$WD" ];
then 
echo '### Docker not installed! Canceled ###'
exit 1
else
echo ' ### Docker installed, startind make build... ###'
mkdir -p "${HER}"/Build && \
rm -rf "${HER}"/Build/* && \
docker run -i --name builder-appimage --privileged -v "${HER}"/Build:/opt/ debian:9-slim /bin/bash -c 'apt-get update && \
apt-get install git fuse curl wget file binutils glib-2.0.0 -y && cd opt/ && \
git clone https://github.com/bro2020/acestream-appimage.git && cd acestream-appimage/ && \
./pkg2appimage.appimage recipes/acestream.yml' && \
docker rm builder-appimage && \
docker rmi debian:9-slim && \
sudo mv "${HER}"/Build/acestream-appimage/out/* "${HER}"/Build/ && \
sudo rm -rf "${HER}"/Build/acestream-appimage/ ; \
sudo chown -R $USER:$USER "${HER}"/Build/ ; \
echo '### Build Completed! AppImage file in directory 'Build' ###'
fi
