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

# build_libssh2.sh
#
# This program automates the process of building the libssh2 library for use
# in an iOS application or for use by other libraries that depend on libssh2.
#
# Usage: bin/build_libssh2.sh

SCRIPT_DIR=$(dirname $0)
pushd $SCRIPT_DIR/.. > /dev/null
ROOT_PATH=$PWD
popd > /dev/null

PLATFORMS="OS SIMULATOR CATALYST"
for PLATFORM in $PLATFORMS
do
    echo "Building libssh2 for $PLATFORM"

    rm -rf /tmp/libssh2
    cp -r External/libssh2 /tmp/

    pushd /tmp/libssh2 > /dev/null

    LOG=/tmp/libssh2-$PLATFORM.log
    rm -f $LOG

    OUTPUT_PATH=$ROOT_PATH/build/libssh2/$PLATFORM
    rm -rf $OUTPUT_PATH

    case $PLATFORM in
        "OS" )
            OPENSSL_ROOT_DIR=$ROOT_PATH/build/openssl/ios
            OPENSSL_CRYPTO_LIBRARY=$ROOT_PATH/build/openssl/lib-ios/libcrypto.a
            OPENSSL_SSL_LIBRARY=$ROOT_PATH/build/openssl/lib-ios/libssl.a
            ;;

        "SIMULATOR" )
            OPENSSL_ROOT_DIR=$ROOT_PATH/build/openssl/iossimulator
            OPENSSL_CRYPTO_LIBRARY=$ROOT_PATH/build/openssl/lib-iossimulator/libcrypto.a
            OPENSSL_SSL_LIBRARY=$ROOT_PATH/build/openssl/lib-iossimulator/libssl.a
            ;;

        "CATALYST" )
            OPENSSL_ROOT_DIR=$ROOT_PATH/build/openssl/catalyst
            OPENSSL_CRYPTO_LIBRARY=$ROOT_PATH/build/openssl/lib-catalyst/libcrypto.a
            OPENSSL_SSL_LIBRARY=$ROOT_PATH/build/openssl/lib-catalyst/libssl.a
            ;;
    esac

    OPENSSL_INCLUDE_DIR=$OPENSSL_ROOT_DIR/include

    mkdir bin
    cd bin
    cmake \
        -DCMAKE_TOOLCHAIN_FILE=$ROOT_PATH/External/cmake/iOS.cmake \
        -DIOS_PLATFORM=$PLATFORM \
        -DCMAKE_INSTALL_PREFIX=$OUTPUT_PATH \
        -DCRYPTO_BACKEND=OpenSSL \
        -DOPENSSL_ROOT_DIR=$OPENSSL_ROOT_DIR \
        -DOPENSSL_CRYPTO_LIBRARY=$OPENSSL_CRYPTO_LIBRARY \
        -DOPENSSL_SSL_LIBRARY=$OPENSSL_SSL_LIBRARY \
        -DOPENSSL_INCLUDE_DIR=$OPENSSL_INCLUDE_DIR \
        .. >> $LOG 2>&1
    cmake --build . --target install >> $LOG 2>&1

    popd > /dev/null
done

echo "Creating the XCFramework"

LIB_PATH=$ROOT_PATH/lib/libssh2
LIBSSH2_PATH=$LIB_PATH/libssh2.xcframework
rm -rf $LIBSSH2_PATH
mkdir -p $LIB_PATH

xcodebuild -create-xcframework \
    -library $ROOT_PATH/build/libssh2/OS/lib/libssh2.a \
    -headers $ROOT_PATH/build/libssh2/OS/include \
    -library $ROOT_PATH/build/libssh2/SIMULATOR/lib/libssh2.a \
    -headers $ROOT_PATH/build/libssh2/SIMULATOR/include \
    -library $ROOT_PATH/build/libssh2/CATALYST/lib/libssh2.a \
    -headers $ROOT_PATH/build/libssh2/CATALYST/include \
    -output $LIBSSH2_PATH

pushd $LIB_PATH > /dev/null
zip -r ../libssh2.zip .
popd > /dev/null

echo "Done; cleaning up"
rm -rf /tmp/libssh2
