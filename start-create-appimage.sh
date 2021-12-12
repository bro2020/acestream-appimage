#!/bin/bash
USER=$USER
HER=$(dirname $(readlink -f "${0}"))
docker run -i --name builder-appimage --privileged -v "${HER}"/build:/opt/ debian:9-slim /bin/bash -c 'apt-get update && apt-get install git fuse curl wget dpkg-cross glib-2.0.0 -y && cd opt/ && git clone https://github.com/bro2020/acestream-appimage.git && cd acestream-appimage/ && ./pkg2appimage.appimage recipes/acestream.yml'
docker rm builder-appimage
docker rmi debian:9-slim
sudo mv "${HER}"/build/acestream-appimage/out/* "${HER}"/build/
sudo rm -rf "${HER}"/build/acestream-appimage/
sudo chown -R $USER:$USER "${HER}"/build/
