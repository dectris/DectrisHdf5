#!/bin/bash
#
# Jenkins Job Build Script call
#

# Fetch project name from the CMakeList.txt file
PROJECT_NAME=$(grep -i "project (" CMakeLists.txt  | awk -F "[)]| |[(]" '{print $3}'); 

# Fetch project version number from the CMakeList.txt file
PROJECT_VERSION=$(grep -i "set (VERSION_MAJOR" CMakeLists.txt | sed 's/(//g' | sed 's/)//g' | tr -s ' ' | cut -d' ' -f 3).$(grep -i "set (VERSION_MINOR" CMakeLists.txt | sed 's/(//g' | sed 's/)//g' | tr -s ' ' | cut -d' ' -f 3).$(grep -i "set (VERSION_PATCH" CMakeLists.txt | sed 's/(//g' | sed 's/)//g' | tr -s ' ' | cut -d' ' -f 3)

export RPM_NOTE=$(echo ${GIT_BRANCH} | sed 's/origin\//Branch: /g')

BRANCH_TAG=$(echo ${GIT_BRANCH} | sed 's/origin\///g' | sed 's/\//_/g')
BUILDER_NAME=builder_${PROJECT_NAME}-${BRANCH_TAG}-${BUILD_NUMBER}

TOTALCPUs=$(grep -c ^processor /proc/cpuinfo)
NCPUs=$((${TOTALCPUs} / ${EXECUTORS} ))
DOCKER_BUILDER="dectris/eiger-builder:"$(echo ${OS_VERSION} | cut -d "_" -f2)

echo "Project:      ${PROJECT_NAME}-${PROJECT_VERSION}"
echo "CPUs:         ${NCPUs}/${TOTALCPUs} CPUs"
echo "Local path:   $(pwd)"
echo "Docker:       $(docker -v)"
echo "Builder HW:   $(hostname) ("$(python -c 'import socket; s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM); s.connect(("192.168.50.1",80)); print(s.getsockname()[0]); s.close()')")"
echo "Builder Name: ${DOCKER_BUILDER}"


docker rm $BUILDER_NAME 2&>/dev/null || true 
if   [[ "${OS_VERSION}" == "6.5" ]]; then 
    DOCKER_BUILDER_CMD="docker run --privileged=true  --name $BUILDER_NAME -v $(pwd):/scratch -t ${DOCKER_BUILDER} /scratch/.ci/pack.sh -b ${BUILD_NUMBER} -n ${NCPUs} -c devtoolset-1.1"

elif [[ "${OS_VERSION}" == "7.2" ]]; then 
    DOCKER_BUILDER_CMD="docker run --privileged=true  --name $BUILDER_NAME -v $(pwd):/scratch -t ${DOCKER_BUILDER} /scratch/.ci/pack.sh -b ${BUILD_NUMBER} -n ${NCPUs}"
else
    echo "'${OS_VERSION}' not supported" 
    exit(1)
fi

echo "Starting Docker Builder [${DOCKER_BUILDER_CMD}]"
$DOCKER_BUILDER_CMD
docker wait $BUILDER_NAME
docker logs -f $BUILDER_NAME
echo "Removing Docker Builder"
docker rm $BUILDER_NAME 2&>/dev/null || true 


