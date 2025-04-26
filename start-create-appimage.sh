#!/bin/bash
USER=$USER
HER="$(dirname $(readlink -f "${0}"))"
WD=$(whereis docker)
VER=$(cat "$HER"/VERSION)
ACE_VERSION=$(cat "$HER"/ACE_VERSION)
BUILD_TIME=$(date +_%d-%m-%Y_%H-%M)
BUILD=${ACE_VERSION}${BUILD_TIME}_${VER}
COMMAND="apt-get update && \
apt-get install fuse curl wget file desktop-file-utils binutils libglib2.0-0 graphicsmagick-imagemagick-compat -y && \
cd opt/ && \
ACE_VERSION=$ACE_VERSION USER=$USER ./pkg2appimage.appimage recipes/acestream.yml"
if [[ "$@" = "-h" ]] || [[ "$@" = "--help" ]]; then
  echo "
Версія: $VER

Запуск скрипту без ключа передбачає перевірку наявності в системі встановленого docker і запуск створення AppImage файлу в контейнері
    -t            - виконує примусовий запуск білда без докера, в поточному вікні терміналу
    -h --help     - виводить цю підказку
У разі неможливості виявлення в системі встановленого docker, виконується запуск білда без використання докера, в поточному вікні терміналу.
  "
  exit 0
fi
if [[ "$@" = "-t" ]]; then
  WD=''
fi
if [ -z "$WD" ]; then
  echo "
### Версія: $VER ###
### Docker не виявлено! Пробую запустити створення білда в поточній ОС ###
  "
  sleep 3
  rm -vrf "${HER}"/acestream-$ACE_VERSION "${HER}"/out && \
  ACE_VERSION=$ACE_VERSION USER=$USER ./pkg2appimage.appimage recipes/acestream.yml && \
  mkdir -vp "${HER}"/build/$BUILD && \
  mv -v "${HER}"/out/* "${HER}"/build/$BUILD/AceStream-"$ACE_VERSION"-$VER.AppImage && \
  cp -v "${HER}"/acestream.conf "${HER}"/build/$BUILD/ && \
  sed -i "s/\$USER/$USER/g" "${HER}"/build/$BUILD/acestream.conf && \
  chown -vR $USER:$USER "${HER}"/build/$BUILD/* && \
  rm -vrf "${HER}"/acestream-$ACE_VERSION "${HER}"/out && \
  echo "$BUILD" > "${HER}"/CURRENT_BUILD && \
  echo "
### Створення білда успішно завершено! Шлях до AppImage файлу: ./build/$BUILD/AceStream-$ACE_VERSION-$VER.AppImage ###
  " && \
  exit 0 || \
  rm -vrf "${HER}"/acestream-$ACE_VERSION "${HER}"/out; \
  echo '
### Виникла критична помилка! ###
  '; \
  exit 1
else
  echo "
### Версія: $VER ###
### Docker виявлено! Запуск створення білда в docker контейнері debian:10-slim... ###
  "
  sudo rm -vrf /tmp/builder-appimage/* && \
  mkdir -vp /tmp/builder-appimage && \
  set -x
  docker run --rm -i --privileged \
   --name builder-appimage \
   -e ACE_VERSION=$ACE_VERSION \
   -e USER=$USER \
   -v /tmp/builder-appimage:/opt \
   -v ./pkg2appimage.appimage:/opt/pkg2appimage.appimage \
   -v ./recipes:/opt/recipes \
   debian:10-slim /bin/bash -c "$COMMAND" && \
  set +x
  sleep 1
  docker rmi debian:10-slim || \
  echo "Docker image 'debian:10-slim' not removed!" && \
  mkdir -vp "${HER}"/build/$BUILD && \
  sudo mv -v /tmp/builder-appimage/out/* "${HER}"/build/$BUILD/AceStream-"$ACE_VERSION"-$VER.AppImage && \
  cp -v "${HER}"/acestream.conf "${HER}"/build/$BUILD/ && \
  sed -i "s/\$USER/$USER/g" "${HER}"/build/$BUILD/acestream.conf && \
  sudo rm -vrf /tmp/builder-appimage && \
  sudo chown -vR $USER:$USER "${HER}"/build/$BUILD/* && \
  echo "$BUILD" > "${HER}"/CURRENT_BUILD && \
  echo "
### Створення білда успішно завершено! Шлях до AppImage файлу: ./build/$BUILD/AceStream-$ACE_VERSION-$VER.AppImage ###
  " && \
  exit 0 || \
  sudo rm -vrf /tmp/builder-appimage; \
  echo '
### Виникла критична помилка! ###
  '; \
  exit 1
fi
