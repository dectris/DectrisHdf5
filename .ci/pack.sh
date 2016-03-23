#!/bin/bash

# Determine absolute pash if passing throught Docker contained volume mapping
pushd `dirname $0` > /dev/null
SCRIPT_PATH=`pwd -P`
popd > /dev/null

pushd $SCRIPT_PATH/.. > /dev/null

# Fetch the code
# TYPES=$(grep CMAKE_BUILD_TYPE ./CMakeLists.txt | grep STREQUAL | grep -v "#" | tr -d '()"${}' |  awk -F " " '{print $4" "}'| tr -d '\n')

# Fetch the available SCLs
SCL_LIST=$(scl -l | grep devtoolset | tr '\n' ' ')

usage() {
    echo "Usage: $0 -t <system_type> -c <number_of_cpus>"
    echo "   -n number of CPU to use"
    echo "   -c SCL compiler to use: [ $SCL_LIST]"
    echo "   -b Build number to assign"
    echo "   -a artifact destination"
    echo "   -d don't purge build folder before and after building"
}

while getopts ":t:h:n:c:b:a:d" o; do
    case "${o}" in
        a)
            export ARTIFACT_DESTINATION=${OPTARG}
	    ;;
	c)
            SCL_COMPILER=${OPTARG}
            ;;
        d)
            export DEVELOPER_MODE=true
	    ;;
        n)
            NCPUs=${OPTARG}
            ;;
	b)  
	    export BUILD_NUMBER=${OPTARG}
	    ;;  
        h)
            usage
            exit 
            ;;
        *)
            usage
            exit 
            ;;
    esac
done

shift $((OPTIND-1))
echo "Compiling and packaging shortcuts"
echo ""

TIMESTAMP=$(date +%s)
DATE=$(date +%Y%m%d)

if [[ -z "${SCL_COMPILER}" ]] ; then
    echo "Using default compiler"
else
    echo "Using $SCL_COMPILER"
    source /opt/centos/${SCL_COMPILER}/enable
fi

if [[ -z "${BUILD_NUMBER}" ]] ; then
    export BUILD_NUMBER=$TIMESTAMP
fi

if [[ -z "${NCPUs}" ]] ; then
    NCPUs=$(grep -c ^processor /proc/cpuinfo)
fi

# Satisfy dependencies
export COMPILER_NAME="GCC"

GIT_HASH=$(git log --pretty=format:'%h' -n 1)
#GIT_BRANCH=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p' | sed 's/\//-/g')
DIST_TAG=".$(rpm --showrc | grep dist| grep '\.el' | awk -F ' ' '{print $3}' | cut -d "." -f2)"

BUILD_NUMBER="${BUILD_NUMBER}.git${GIT_HASH}${DIST_TAG}"

./.ci/satiate.sh
# Build
if [[ -z $DEVELOPER_MODE ]]; then 
    rm -rf build
fi
rm *.rpm

mkdir build
cd build

cmake ../ && make -j$NCPUs package || exit

RPMNAME=$(basename *.git${GIT_HASH}*.rpm  | sed 's/.x86_64.rpm//g' )".x86_64.rpm"

mv *.git${GIT_HASH}*.rpm $RPMNAME

if [[ -z "${ARTIFACT_DESTINATION}" ]] ; then
    cp *.rpm ../
else
    cp *.rpm $ARTIFACT_DESTINATION
fi
popd > /dev/null
