#!/bin/bash
set -e

# common variables
CURRENT_DIR=`pwd`
SCRIPT_DIR=`dirname $0`

red=$(tput setaf 1)
reset=$(tput sgr0)

# build variables
BUILD_DATE=$(date -u +'%Y-%m-%d-%H:%M:%S')
BUILD_VERSION=${1:-"v2.0.0-beta1"}
ORG='edowson'
IMAGE_PREFIX='tf'
IMAGE_FEATURE=${2:-"gpu"}
#REPOSITORY="$ORG/$IMAGE"
BUILD_IMAGE="$IMAGE_PREFIX-build"
BUILD_OUTPUT=${6:-"/tmp/build"}
BASE_IMAGE="$IMAGE_PREFIX-base"
DEV_BASE_IMAGE="$IMAGE_PREFIX-dev-base"
PYTHON_VERSION=${3:-"3.6"}
OS_DISTRO=${4:-"ubuntu"}
CODE_NAME=${5:-"xenial"}
TAG="$BUILD_VERSION-$CODE_NAME"


# step 01: build the `tf-build` docker image, which will contain the generated pip wheel package.
echo "${red}building image $BUILD_IMAGE${reset}";
cd $CURRENT_DIR/$OS_DISTRO/$BUILD_IMAGE
/bin/bash ./build.sh "$BUILD_VERSION" "$IMAGE_FEATURE" "$PYTHON_VERSION" "$OS_DISTRO" "$CODE_NAME"

echo "${red}running image $BUILD_IMAGE to copy generated build artifacts to $BUILD_OUTPUT${reset}";
/bin/bash ./run.sh "$BUILD_VERSION" "$IMAGE_FEATURE" "$PYTHON_VERSION" "$OS_DISTRO" "$CODE_NAME" "$BUILD_OUTPUT"

# step 02: build the tf-base` docker image.
echo "${red}building image $BASE_IMAGE${reset}";
cd $CURRENT_DIR/$OS_DISTRO/$BASE_IMAGE
/bin/bash ./build.sh "$BUILD_VERSION" "$IMAGE_FEATURE" "$PYTHON_VERSION" "$OS_DISTRO" "$CODE_NAME"
