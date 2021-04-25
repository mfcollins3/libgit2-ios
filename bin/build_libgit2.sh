#!/usr/bin/env bash

# Copyright 2021 Naked Software, LLC
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# build_libgit2.sh
#
# This program automates the steps required to build libgit2 in order to be
# linked into an iOS application or framework, or linked with another library
# that depends on libgit2 for iOS.
#
# Usage: bin/build_libgit2.sh

SCRIPT_DIR=$(dirname $0)
pushd $SCRIPT_DIR/.. > /dev/null
ROOT_PATH=$PWD
popd > /dev/null

PLATFORMS="OS SIMULATOR CATALYST"
for PLATFORM in $PLATFORMS
do
    echo "Building libgit2 for $PLATFORM"

    rm -rf /tmp/libgit2
    cp -r External/libgit2 /tmp/

    pushd /tmp/libgit2 > /dev/null

    LOG=/tmp/libgit2-$PLATFORM.log
    rm -f $LOG

    OUTPUT_PATH=$ROOT_PATH/build/libgit2/$PLATFORM
    rm -rf $OUTPUT_PATH

    case $PLATFORM in
        "OS" )
            OPENSSL_ROOT_DIR=$ROOT_PATH/build/openssl/ios
            OPENSSL_LIBRARIES_DIR=$ROOT_PATH/build/openssl/lib-ios
            ;;

        "SIMULATOR" )
            OPENSSL_ROOT_DIR=$ROOT_PATH/build/openssl/iossimulator
            OPENSSL_LIBRARIES_DIR=$ROOT_PATH/build/openssl/lib-iossimulator
            ;;

        "CATALYST" )
            OPENSSL_ROOT_DIR=$ROOT_PATH/build/openssl/catalyst
            OPENSSL_LIBRARIES_DIR=$ROOT_PATH/build/openssl/lib-catalyst
            ;;
    esac

    OPENSSL_INCLUDE_DIR=$OPENSSL_ROOT_DIR/include
    OPENSSL_CRYPTO_LIBRARY=$OPENSSL_LIBRARIES_DIR/libcrypto.a
    OPENSSL_SSL_LIBRARY=$OPENSSL_LIBRARIES_DIR/libssl.a
    LIBSSH2_ROOT_DIR=$ROOT_PATH/build/libssh2/$PLATFORM

    mkdir bin
    cd bin
    cmake \
        -DCMAKE_TOOLCHAIN_FILE=$ROOT_PATH/External/cmake/iOS.cmake \
        -DIOS_PLATFORM=$PLATFORM \
        -DCMAKE_INSTALL_PREFIX=$OUTPUT_PATH \
        -DOPENSSL_ROOT_DIR=$OPENSSL_ROOT_DIR \
        -DOPENSSL_CRYPTO_LIBRARY=$OPENSSL_CRYPTO_LIBRARY \
        -DOPENSSL_SSL_LIBRARY=$OPENSSL_SSL_LIBRARY \
        -DOPENSSL_INCLUDE_DIR=$OPENSSL_INCLUDE_DIR \
        -DUSE_SSH=OFF \
        -DLIBSSH2_FOUND=TRUE \
        -DLIBSSH2_INCLUDE_DIRS=$LIBSSH2_ROOT_DIR/include \
        -DLIBSSH2_LIBRARY_DIRS=$LIBSSH2_ROOT_DIR/lib \
        -DLIBSSH2_LIBRARIES="-L$LIBSSH2_ROOT_DIR/lib -L$OPENSSL_LIBRARIES_DIR -lssh2 -lssl -lcrypto" \
        -DBUILD_SHARED_LIBS=OFF \
        -DBUILD_CLAR=OFF \
        .. >> $LOG 2>&1
    cmake --build . --target install >> $LOG 2>&1

    popd > /dev/null
done

echo "Creating the XCFramework"

LIB_PATH=$ROOT_PATH/lib/libgit2
LIBGIT2_PATH=$LIB_PATH/libgit2.xcframework
rm -rf $LIBGIT2_PATH
mkdir -p $LIB_PATH

xcodebuild -create-xcframework \
    -library $ROOT_PATH/build/libgit2/OS/lib/libgit2.a \
    -headers $ROOT_PATH/build/libgit2/OS/include \
    -library $ROOT_PATH/build/libgit2/SIMULATOR/lib/libgit2.a \
    -headers $ROOT_PATH/build/libgit2/SIMULATOR/include \
    -library $ROOT_PATH/build/libgit2/CATALYST/lib/libgit2.a \
    -headers $ROOT_PATH/build/libgit2/CATALYST/include \
    -output $LIBGIT2_PATH

pushd $LIB_PATH > /dev/null
zip -r ../libgit2.zip .
popd > /dev/null

echo "Done; cleaning up"
rm -rf /tmp/libgit2
