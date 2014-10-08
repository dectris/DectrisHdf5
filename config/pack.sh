#!/bin/bash
# Fetch the code
SCL_COMPILER=$1
CPUs=$2
BUILD_TYPE=$3

source /opt/centos/$SCL_COMPILER/enable
# Satisfy dependencies
cd /scratch
./config/satiate.sh
# Build
rm -rf build
mkdir build
cd build

export BUILD_NUMBER="$4"
export COMPILER_NAME="gcc"
echo $BUILD_NUMBER
echo $COMPILER_NAME
cmake ../ -DCMAKE_BUILD_TYPE=$BUILD_TYPE;
make -j $CPUs package 

# Archive Artifact
#ORIGINAL_PACKAGE_NAME=$(ls -1 *.rpm)
#PACKAGE_NAME=$(basename *.rpm .rpm)"_b"${BUILD_NUMBER}.rpm

# Copy package in the local repository (which is NFS for the time being)
cp *.rpm /mnt/NFS/
