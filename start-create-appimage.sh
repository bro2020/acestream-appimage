#!/bin/bash
USER=$USER
HER=$(dirname $(readlink -f "${0}"))
WD=$(whereis docker)
VERSION=`cat VERSION`
COMMAND="apt-get update && \
apt-get install git fuse curl wget file binutils glib-2.0.0 -y && \
cd opt/ && \
git clone https://github.com/bro2020/acestream-appimage.git && \
cd acestream-appimage/ && \
./pkg2appimage.appimage recipes/acestream.yml"
if [ -z "$WD" ];
then 
echo '### Docker not installed! Canceled ###'
exit 1
else
echo ' ### Docker installed, startind make build... ###'
mkdir -p "${HER}"/Build/"$VERSION" && \
rm -rf "${HER}"/Build/"$VERSION"/* && \
docker run -i --name builder-appimage -e VERSION="$VERSION" --privileged -v "${HER}"/Build/"$VERSION":/opt/ debian:9-slim /bin/bash -c "$COMMAND" && \
docker rm builder-appimage && \
docker rmi debian:9-slim && \
sudo mv "${HER}"/Build/"$VERSION"/acestream-appimage/out/* "${HER}"/Build/"$VERSION" && \
sudo rm -rf "${HER}"/Build/"$VERSION"/acestream-appimage/ ; \
sudo chown -R $USER:$USER "${HER}"/Build/"$VERSION"/ ; \
echo "### Build Completed! AppImage file in directory \"Build/$VERSION\" ###"
fi
