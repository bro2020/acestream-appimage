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
Версия: $VER

Запуск скрипта без ключей подразумевает проверку наличия в системе docker и запуск создания билда в контейнере
    -t            - выполняет принудительный запуск билда без докера в текущем окне терминала
    -h --help     - выводит эту подсказку
В случае не обнаружения в системе docker выполняется запуск билда без докера в текущем окне терминала
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
### Версия: $VER ###
### Docker не обнаружен! Пробую запустить создание билда в текущей ОС ###
"
sleep 3
rm -rf "${HER}"/acestream-$ACE_VERSION "${HER}"/out && \
<<<<<<< HEAD
ACE_VERSION=$ACE_VERSION USER=$USER ./pkg2appimage.appimage recipes/acestream.yml && \
mkdir -p "${HER}"/build/$BUILD && \
mv "${HER}"/out/* "${HER}"/build/$BUILD/AceStream-"$ACE_VERSION"-$VER.AppImage && \
sed -i "s/USER/$USER/g" "${HER}"/acestream.conf
cp "${HER}"/acestream.conf "${HER}"/build/$BUILD/ && \
=======
ACE_VERSION=$ACE_VERSION ./pkg2appimage.appimage recipes/acestream.yml && \
mkdir -p "${HER}"/build/$BUILD && \
mv "${HER}"/out/* "${HER}"/build/$BUILD/AceStream-"$ACE_VERSION"-$VER.AppImage && \
>>>>>>> origin/master
chown -R $USER:$USER "${HER}"/build/$BUILD/* && \
rm -rf "${HER}"/acestream-$ACE_VERSION "${HER}"/out && \
echo "$BUILD" > "${HER}"/CURRENT_BUILD && \
echo "
### Создание билда успешно завершено! Путь к AppImage файлу: ./build/$BUILD/AceStream-$ACE_VERSION-$VER.AppImage ###
" && \
exit 0 || rm -rf "${HER}"/acestream-$ACE_VERSION "${HER}"/out; echo '
### Произошла критическая ошибка! ###
'; exit 1
else
echo "
### Версия: $VER ###
### Docker обнаружен! Запуск создания билда в docker контейнере debian:9-slim... ###
"
mkdir -p "${HER}"/tmp && \
rm -rf "${HER}"/tmp/* && \
docker run -i --name builder-appimage -e ACE_VERSION=$ACE_VERSION -e USER=$USER --privileged -v "${HER}"/tmp:/opt/ debian:9-slim /bin/bash -c "$COMMAND" && \
docker rm builder-appimage && \
docker rmi debian:9-slim && \
mkdir -p "${HER}"/build/$BUILD && \
sudo mv "${HER}"/tmp/acestream-appimage/out/* "${HER}"/build/$BUILD/AceStream-"$ACE_VERSION"-$VER.AppImage && \
<<<<<<< HEAD
sed -i "s/USER/$USER/g" "${HER}"/acestream.conf
cp "${HER}"/acestream.conf "${HER}"/build/$BUILD/ && \
=======
>>>>>>> origin/master
sudo rm -rf "${HER}"/tmp && \
sudo chown -R $USER:$USER "${HER}"/build/$BUILD/* && \
echo "$BUILD" > "${HER}"/CURRENT_BUILD && \
echo "
### Создание билда успешно завершено! Путь к AppImage файлу: ./build/$BUILD/AceStream-$ACE_VERSION-$VER.AppImage ###
" && \
exit 0 || docker rm builder-appimage; \
docker rmi debian:9-slim; sudo rm -rf "${HER}"/tmp; echo '
### Произошла критическая ошибка! ###
'; exit 1
fi
