#!/bin/bash
USER=$USER
HER=$(dirname $(readlink -f "${0}"))
WD=$(whereis docker)
VER=`cat $HER/VERSION`
ACE_VERSION=`cat $HER/ACE_VERSION`
BUILD_TIME=$(date +_%d-%m-%Y_%H-%M)
BUILD=${ACE_VERSION}${BUILD_TIME}_${VER}
COMMAND="apt-get update && \
apt-get install git fuse curl wget file binutils glib-2.0.0 -y && \
cd opt/ && \
git clone https://github.com/bro2020/acestream-appimage.git && \
cd acestream-appimage/ && \
ACE_VERSION=\"$ACE_VERSION\" USER=$USER ./pkg2appimage.appimage recipes/acestream.yml"
if [[ "$@" = "-h" ]] || [[ "$@" = "--help" ]];
then
echo "
Версія: $VER

Запуск скрипту без ключа передбачає перевірку наявності в системі встановленого docker і запуск створення AppImage файлу в контейнері
    -t            - виконує примусовий запуск білда без докера, в поточному вікні терміналу
    -h --help     - виводить цю підказку
У разі неможливості виявлення в системі встановленого docker, виконується запуск білда без використання докера, в поточному вікні терміналу.
"
exit 0
fi
if [[ "$@" = "-t" ]];
then
WD=''
fi
if [ -z "$WD" ];
then 
echo "
### Версія: $VER ###
### Docker не виявлено! Пробую запустити створення білда в поточній ОС ###
"
sleep 3
rm -rf "${HER}"/acestream-$ACE_VERSION "${HER}"/out && \
ACE_VERSION=$ACE_VERSION USER=$USER ./pkg2appimage.appimage recipes/acestream.yml && \
mkdir -p "${HER}"/build/$BUILD && \
mv "${HER}"/out/* "${HER}"/build/$BUILD/AceStream-"$ACE_VERSION"-$VER.AppImage && \
sed -i "s/USER/$USER/g" "${HER}"/acestream.conf
cp "${HER}"/acestream.conf "${HER}"/build/$BUILD/ && \
chown -R $USER:$USER "${HER}"/build/$BUILD/* && \
rm -rf "${HER}"/acestream-$ACE_VERSION "${HER}"/out && \
echo "$BUILD" > "${HER}"/CURRENT_BUILD && \
echo "
### Створення білда успішно завершено! Шлях до AppImage файлу: ./build/$BUILD/AceStream-$ACE_VERSION-$VER.AppImage ###
" && \
exit 0 || rm -rf "${HER}"/acestream-$ACE_VERSION "${HER}"/out; echo '
### Виникла критична помилка! ###
'; exit 1
else
echo "
### Версія: $VER ###
### Docker виявлено! Запуск створення білда в docker контейнері debian:9-slim... ###
"
mkdir -p "${HER}"/tmp && \
rm -rf "${HER}"/tmp/* && \
docker run -i --name builder-appimage -e ACE_VERSION=$ACE_VERSION -e USER=$USER --privileged -v "${HER}"/tmp:/opt/ debian:9-slim /bin/bash -c "$COMMAND" && \
docker rm builder-appimage && \
docker rmi debian:9-slim && \
mkdir -p "${HER}"/build/$BUILD && \
sudo mv "${HER}"/tmp/acestream-appimage/out/* "${HER}"/build/$BUILD/AceStream-"$ACE_VERSION"-$VER.AppImage && \
sed -i "s/USER/$USER/g" "${HER}"/acestream.conf
cp "${HER}"/acestream.conf "${HER}"/build/$BUILD/ && \
sudo rm -rf "${HER}"/tmp && \
sudo chown -R $USER:$USER "${HER}"/build/$BUILD/* && \
echo "$BUILD" > "${HER}"/CURRENT_BUILD && \
echo "
### Створення білда успішно завершено! Шлях до AppImage файлу: ./build/$BUILD/AceStream-$ACE_VERSION-$VER.AppImage ###
" && \
exit 0 || docker rm builder-appimage; \
docker rmi debian:9-slim; sudo rm -rf "${HER}"/tmp; echo '
### Виникла критична помилка! ###
'; exit 1
fi
