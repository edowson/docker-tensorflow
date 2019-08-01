#!/bin/bash

# common variables
CURRENT_DIR=`pwd`
SCRIPT_DIR=`dirname $0`

# script variables
HOST_IP=`hostname -I | awk '{print $1}'`
DOCKER_DAEMON_IP=`ip -4 -o a | grep docker0 | awk '{print $4}'`
BUILD_VERSION=${1:-"v2.0.0-beta1"}
ORG='edowson'
IMAGE='tf-base'
IMAGE_FEATURE='gpu'
REPOSITORY="$ORG/$IMAGE/$IMAGE_FEATURE"
CUDA_MAJOR_VERSION='10.1'
CUDNN_VERSION='7.6.2.24'
CONDA_PYTHON_VERSION='3'
CONDA_BASE_PACKAGE='miniconda'
CONDA_VERSION='4.7.10'
NCCL2_VERSION='2.4.7'
TENSORFLOW_VERSION="$BUILD_VERSION"
TENSORRT_VERSION='5.1.5.0'
TF_PYTHON_VERSION=${3:-"3.6"}
USER='developer'
USER_ID='1000'
CODE_NAME='xenial'
TAG="$TENSORFLOW_VERSION-$CUDA_MAJOR_VERSION-$CODE_NAME"
OPTION=""

# setup pulseaudio cookie
if [ x"$(pax11publish -d)" = x ]; then
    start-pulseaudio-x11;
    echo `pax11publish -d | grep --color=never -Po '(?<=^Cookie: ).*'`
fi

# find a free port
read LOWERPORT UPPERPORT < /proc/sys/net/ipv4/ip_local_port_range
while : ; do
  PULSE_PORT="`shuf -i $LOWERPORT-$UPPERPORT -n 1`"
  ss -lpn | grep -q ":$PULSE_PORT " || break
done
echo "Using PULSE_PORT=$PULSE_PORT"

# load pulseaudio tcp module
PULSE_MODULE_ID=$(pactl load-module module-native-protocol-tcp port=$PULSE_PORT)
echo "PULSE_MODULE_ID=$PULSE_MODULE_ID"

# run container
xhost +local:root
docker run -it \
  --runtime=nvidia \
  --device /dev/snd \
  -e DISPLAY \
  -e PULSE_SERVER="tcp:$HOST_IP:$PULSE_PORT" \
  -e PULSE_COOKIE_DATA=`pax11publish -d | grep --color=never -Po '(?<=^Cookie: ).*'` \
  -e QT_GRAPHICSSYSTEM=native \
  -e QT_X11_NO_MITSHM=1 \
  -e NCCL_VERSION="$NCCL2_VERSION" \
  -v /dev/shm:/dev/shm \
  -v /etc/localtime:/etc/localtime:ro \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v /var/run/dbus/system_bus_socket:/var/run/dbus/system_bus_socket:ro \
  -v ${XDG_RUNTIME_DIR}/pulse/native:/run/user/1000/pulse/native \
  -v ~/mount/backup:/backup \
  -v ~/mount/data:/data \
  -v ~/mount/project:/project \
  -v ~/mount/tool:/tool \
  --rm \
  --name ${IMAGE}-${TAG} \
  ${REPOSITORY}:${TAG} bash

xhost -local:root

# unload pulseaudio module
pactl unload-module $PULSE_MODULE_ID
