# acestream-appimage
Сдесь собраны мои bash скрипты, и рецепт для сборки AppImage пакета  сервера ***AceStream*** в ***pkg2appimage***. Скрипт, с помощью Docker контейнера на базе
docker имеджа debian:9-slim, билдит AppImage файл содержащий в себе 
[`AceStream-3.1.49`](https://download.acestream.media/linux/acestream_3.1.49_debian_9.9_x86_64.tar.gz), 
взятый на официальном ресурсе [wiki.acestream.media](https://wiki.acestream.media/Download).

Основная боль запуска этого сервера - зависимости `python2.7`, который выпилен на большинстве современных 
десктопных linux операционных системах. 
Причина по которой решил билдить в Docker контейнере - не придется устанавливать зависимости для работы ***pkg2appimage*** засоряя систему. Не стал добиваться возможности работы скрипта без прав `root`. 
Скрипт простой, и не сложно увидеть, что `sudo` используется только для простых операций с файлами, которые создаются в docker volume и владелец у них 
пользователь `root`.
При запуске docker контейнера пришлось использовать ключ `--privileged`. Без этого не работал `fuse` внутри контейнера. В общем это вроде и дыра в безопасности, 
но так как все компоненты проекта OpenSouce, то не критично.
Файл [`pkg2appimage.appimage`](https://github.com/AppImage/pkg2appimage) взят из официального репозитория на GitHub.

Предусмотрена возможность работы сервера только в режиме `--client-console`, но как по мне этого вполне достаточно.
Весь проект занимает ***не больше 100 мб***, при этом пакет сервера занимает в районе ***49 мб***. но в процессе билда понадобится не менее 500-700 мб 
свободного места на диске. Стоит отметить, что скрипт удаляет после себя и docker контейнер и docker имедж и ненужные файлы после билда.

Работа со скриптами предельно проста.
Для создания appimage пакета с AceStream сервером нужно, находять в директории проекта, запустить скрипт:
```
  ./start-create-appimage.sh
```
По умолчанию скрипт проверит наличие в системе docker и если он будет обнаружен, билд будет создаваться в контейнере. Если docker не будет обнаружен,
запуститься создание в текущей консоли.
В процессе выполнения в консоль будет выводиться много информации, что поможет сразу выяснить причины ошибок, 
если такие возникнут. В случае отсутствия ошибок, будет отображена информация об успешном завершении работы скрипта, и где можно найти созданный файл AppImage.

Есть возможность принудительно создать билд без docker, для этого используется ключ `-t`:
```
  ./start-create-appimage.sh -t
```
После успешного создания билда, в терминате отобразится подсказка, по которой можно найти созданный файл AppImage. 

Для запуска сервера требуется конфигурационный файл `./build/$BUILD/acestream.conf`. Наличие файла обязательно! В нем проводится настройка параметров запуска. Минимально должна присутствовать строка `--client-console` и она должна быть самой первой в файле!

Чтобы запустить сервер AceStream достаточно запустить бинарник:
```
  ./build/$BUILD/AceStream-$ACE_VERSION-$VER.AppImage
```
*$BUILD - поддирекотрия с номер билда (генерируется при выполнении скрипта `start-create-appimage.sh`)
$ACE_VERSION-$VER - версия сервера acestream и версия данного проекта*
    
Ключи которые могут использоваться при запуске `acestreamengine`, подставляются только после параметров прописанных в конфигурационном файле `./build/$BUILD/acestream.conf` и не переопределяют их.

Сразу после запуска бинарника, происходит автомастическая интеграция приложения с системой:
  - создается файл иконки `/home/$USER/.local/share/icons/acestream-$ACE_VERSION.png`
  - создается файл запуска сервера `/home/$USER/.local/share/applications/acestream-start-$ACE_VERSION.desktop`
  - создается файл остановки сервера `/home/$USER/.local/share/applications/acestream-stop-$ACE_VERSION.desktop`

После этого сервер AceStream имеет значки запуска и останоки в меню приложений вашего дестрибутива Linux.

Для того, чтобы выпилить приложение из системы достаточно выполнить комманду:
```
   rm -rf /home/$USER/.local/share/applications/acestream-st* /home/$USER/.local/share/icons/acestream-*
```

