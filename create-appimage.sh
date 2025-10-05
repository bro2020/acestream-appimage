#!/bin/bash
# set -x

# Set base variables
USER=$USER
HER="$(dirname $(readlink -f "${0}"))"

# Parsing .env
if [ -f "${HER}/.env" ];then
  source "${HER}/.env"
fi

# Set default variables
DEFAULT_VER=$(cat "${HER}/VERSION")
DEFAULT_ACE_VERSION=$(cat "${HER}/ACE_VERSION")
DEFAULT_ACE_URL_ICON='https://i.ytimg.com/vi/dxar7KLsrg8/hqdefault.jpg'
DEFAULT_ACE_URL_APP="https://download.acestream.media/linux/acestream_${DEFAULT_ACE_VERSION}_ubuntu_22.04_x86_64_py3.10.tar.gz"
DEFAULT_PYTHON_VERSION='3.10.18'
DEFAULT_BUILD_TIME=$(date +_%d-%m-%Y_%H-%M)
DEFAULT_BUILD=${DEFAULT_ACE_VERSION}${DEFAULT_BUILD_TIME}_${DEFAULT_VER}
DEFAULT_INTEGRATION='no'
DEFAULT_WD=$(whereis docker)

# Processing main variables
VER="${VER:-${DEFAULT_VER}}"
ACE_VERSION="${ACE_VERSION:-${DEFAULT_ACE_VERSION}}"
ACE_URL_ICON="${ACE_URL_ICON:-${DEFAULT_ACE_URL_ICON}}"
ACE_URL_APP="${ACE_URL_APP:-${DEFAULT_ACE_URL_APP}}"
PYTHON_VERSION="${PYTHON_VERSION:-${DEFAULT_PYTHON_VERSION}}"
BUILD_TIME="${BUILD_TIME:-${DEFAULT_BUILD_TIME}}"
BUILD="${BUILD:-${DEFAULT_BUILD}}"
if [ -n "$(echo "$@" | sed -rn '/([[:space:]]|^)(-i|--integration)([[:space:]]|$)/p')" ]; then
  INTEGRATION='yes'
else
  INTEGRATION="${INTEGRATION:-${DEFAULT_INTEGRATION}}"
fi
if [ -n "$(echo "$@" | sed -rn '/([[:space:]]|^)(-t|--terminal)([[:space:]]|$)/p')" ]; then
  WD=''
else
  WD="${WD:-${DEFAULT_WD}}"
fi
COMMAND="apt update && \
apt install -y libfuse2t64 gcc curl wget file desktop-file-utils binutils libglib2.0-0 graphicsmagick-imagemagick-compat libgpg-error0 && \
cd opt/ && \
ACE_VERSION=$ACE_VERSION \
USER=$USER \
ACESTREAM_DESKTOP_INTEGRATION=$INTEGRATION \
ACE_URL_ICON=\"$ACE_URL_ICON\" \
ACE_URL_APP=\"$ACE_URL_APP\" \
PYTHON_VERSION=$PYTHON_VERSION \
./pkg2appimage.appimage recipes/acestream.yml"

# Print help message
if [ -n "$(echo "$@" | sed -rn '/([[:space:]]|^)(-h|--help)([[:space:]]|$)/p')" ]; then
  echo "
UA
Версія: $VER

Запуск скрипту без аргументів передбачає перевірку наявності в системі встановленого docker і запуск створення AppImage файлу в контейнері.
    -t --terminal     - виконує примусовий запуск білда без докера, в поточному вікні терміналу
    -i --integration  - включає в виконуваний файл AppRun інтеграцію з системою (.desktop файли та іконка)
    -h --help         - виводить цю підказку
У разі неможливості виявлення в системі встановленого docker, виконується запуск збірки без використання докера, в поточному вікні терміналу.
-------------
EN
Version: $VER

Running the script without arguments involves checking whether docker is installed on the system and starting the creation of the AppImage file in the container.
    -t --terminal     - forces a build without docker, in the current terminal window
    -i --integration  - includes system integration (.desktop files and icon) in the AppRun executable file
    -h --help         - displays this prompt
If it is not possible to detect docker installed on the system, the build is launched without using docker, in the current terminal window.
  "
  exit 0
fi

# Run build appimage
if [ -z "$WD" ]; then
  echo "
### UA
### Версія: $VER ###
### Docker не виявлено! Пробую запустити збірку в поточній ОС ###
------
### EN
### Версія: $VER ###
### Docker not detected! Trying to run build on current OS ###
  "
  sleep 3
  rm -vrf "${HER}/acestream-$ACE_VERSION" "${HER}/out" && \
  ACE_VERSION=$ACE_VERSION USER=$USER ACESTREAM_DESKTOP_INTEGRATION=$INTEGRATION ACE_URL_ICON="$ACE_URL_ICON" ACE_URL_APP="$ACE_URL_APP" PYTHON_VERSION=$PYTHON_VERSION ./pkg2appimage.appimage recipes/acestream.yml && \
  mkdir -vp "${HER}/build/$BUILD" && \
  mv -v "${HER}/out"/* "${HER}/build/$BUILD/AceStream-$ACE_VERSION-$VER.AppImage" && \
  cp -v "${HER}/acestream.conf" "${HER}"/build/$BUILD/ && \
  sed -i "s/\$USER/$USER/g" "${HER}/build/$BUILD/acestream.conf" && \
  chown -vR $USER:$USER "${HER}/build/$BUILD"/* && \
  rm -vrf "${HER}/acestream-$ACE_VERSION" "${HER}/out" && \
  echo "$BUILD" > "${HER}/CURRENT_BUILD" && \
  echo "
### UA
### Збірка успішно завершена! Шлях до AppImage файлу: ./build/$BUILD/AceStream-$ACE_VERSION-$VER.AppImage ###
------
### EN
### The build has been completed successfully! Path to the AppImage file: ./build/$BUILD/AceStream-$ACE_VERSION-$VER.AppImage ###
  " && \
  exit 0 || \
  rm -vrf "${HER}/acestream-$ACE_VERSION" "${HER}/out"; \
  echo '
### UA
### Виникла критична помилка! ###
------
### EN
### A fatal error occurred! ###
  '; \
  exit 1
else
  echo "
### UA
### Версія: $VER ###
### Docker виявлено! Запуск збірки в docker контейнері debian:13-slim... ###
------
### EN
### Version: $VER ###
### Docker detected! Running build in docker container debian:13-slim... ###
  "
  sudo rm -vrf /tmp/builder-appimage/* && \
  mkdir -vp /tmp/builder-appimage && \
  set -x
  docker run --rm -i --privileged \
   --name builder-appimage \
   -v /tmp/builder-appimage:/opt \
   -v ./pkg2appimage.appimage:/opt/pkg2appimage.appimage \
   -v ./recipes:/opt/recipes \
   debian:13-slim /bin/bash -c "$COMMAND" && \
  set +x
  sleep 1
  docker rmi debian:13-slim || \
  echo "Docker image 'debian:13-slim' not removed!" && \
  mkdir -vp "${HER}/build/$BUILD" && \
  sudo mv -v /tmp/builder-appimage/out/* "${HER}/build/$BUILD/AceStream-$ACE_VERSION-$VER.AppImage" && \
  cp -v "${HER}/acestream.conf" "${HER}/build/$BUILD"/ && \
  sed -i "s/\$USER/$USER/g" "${HER}/build/$BUILD/acestream.conf" && \
  sudo rm -rf /tmp/builder-appimage && \
  sudo chown -vR $USER:$USER "${HER}/build/$BUILD"/* && \
  echo "$BUILD" > "${HER}/CURRENT_BUILD" && \
  echo "
### UA
### Збірка успішно завершена! Шлях до AppImage файлу: ./build/$BUILD/AceStream-$ACE_VERSION-$VER.AppImage ###
------
### EN
### The build has been completed successfully! Path to the AppImage file: ./build/$BUILD/AceStream-$ACE_VERSION-$VER.AppImage ###
  " && \
  exit 0 || \
  sudo rm -rf /tmp/builder-appimage; \
  echo '
### UA
### Виникла критична помилка! ###
------
### EN
### A fatal error occurred! ###
  '; \
  exit 1
fi
