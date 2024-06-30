#!/bin/bash
#
# .deb package "Chapter 4. Simple Example" automation
# https://www.debian.org/doc/manuals/debmake-doc/ch04.en.html
#

VERSION=$1


set -eu
set -o pipefail

export LC_ALL='C'

trap 'echo "error:$0($LINENO) \"$BASH_COMMAND\" \"$@\""' ERR


SCRIPT_DIR=$(cd $(dirname $0); pwd)


pushd ${SCRIPT_DIR}/..
    ROOT_DIR=$(pwd)
popd


ORIG_NAME=${ROOT_DIR##*/}
APP_NAME=${ORIG_NAME%-*}


if [[ -z $VERSION ]] && [[ $ORIG_NAME =~ "-" ]]
then
    VERSION=${ORIG_NAME##*-}
fi

if [[ -z $VERSION ]]
then
echo "ERROR: Can't determine the version number for the package.
If you are building a package from a repository clone,
use the syntax: make VERSION=x.x.x"
exit 1
fi



DEB_OBJECT_DIR=${ROOT_DIR}/packages/deb_object
SOURCE_PACKAGE_DIR=${ROOT_DIR}/packages/src
BINARY_PACKAGE_DIR=${ROOT_DIR}/packages/bin
DEB_OVERWRITE=${SCRIPT_DIR}/deb_overwrite
PACKAGE_DIR_NAME=${APP_NAME}-${VERSION}


# set environment value for DEB tools
export DEBEMAIL="windjammer07@gmail.com"
export DEBFULLNAME="Alexander"


# make .tar.gz source package
rm -rf ${DEB_OBJECT_DIR}
mkdir -p ${DEB_OBJECT_DIR}
pushd ${DEB_OBJECT_DIR}
mkdir -p ${PACKAGE_DIR_NAME}


 cp -r ${ROOT_DIR}/src ${PACKAGE_DIR_NAME}/
 cp ${ROOT_DIR}/Makefile ${PACKAGE_DIR_NAME}/
# touch ${PACKAGE_DIR_NAME}/LICENSE

 tar -zcvf ${PACKAGE_DIR_NAME}.tar.gz ${PACKAGE_DIR_NAME}/



# generate default debian setting file and overwrite
pushd ${PACKAGE_DIR_NAME}/

debmake

cp ${DEB_OVERWRITE}/debian/rules     debian/rules
cp ${DEB_OVERWRITE}/debian/control   debian/control
cp ${DEB_OVERWRITE}/debian/copyright debian/copyright


# build .deb file
debuild -us -uc 

# Move source package to src ...
rm -rf ${SOURCE_PACKAGE_DIR}
mkdir -p ${SOURCE_PACKAGE_DIR}
cp ../*.orig.tar.gz ${SOURCE_PACKAGE_DIR}
mv ../*.debian.tar.xz ${SOURCE_PACKAGE_DIR}
mv ../*.dsc ${SOURCE_PACKAGE_DIR}


# ... and binary, to bin
rm -rf ${BINARY_PACKAGE_DIR}
mkdir -p ${BINARY_PACKAGE_DIR}
mv ../*.deb ${BINARY_PACKAGE_DIR}

rm -r ${DEB_OBJECT_DIR}


[ -f ${BINARY_PACKAGE_DIR}/${APP_NAME}_${VERSION}-1_amd64.deb ]


