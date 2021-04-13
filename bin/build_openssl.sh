#!/usr/bin/env bash

# Copyright 2021 Michael F. Collins, III
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

# build.sh
#
# This program automates building OpenSSL to be linked into an iOS application
# or to be used by other libraries that may be linked into an iOS application.
#
# Usage: bin/build.sh

SCRIPT_DIR=$(dirname $0)
pushd $SCRIPT_DIR/.. > /dev/null
ROOT_PATH=$PWD
popd > /dev/null

CONFIGURATIONS="ios ios64 iossimulator catalyst catalyst-arm"
for CONFIGURATION in $CONFIGURATIONS
do
    echo "Building OpenSSL for $CONFIGURATION"

    rm -rf /tmp/openssl
    cp -r External/openssl /tmp/

    pushd /tmp/openssl > /dev/null

    LOG="/tmp/openssl-$CONFIGURATION.log"
    rm -f $LOG

    OUTPUT_PATH=$ROOT_PATH/build/openssl/$CONFIGURATION
    rm -rf $OUTPUT_PATH
    mkdir -p $OUTPUT_PATH

    ./Configure "openssl-$CONFIGURATION" --config=$ROOT_PATH/External/openssl-config/ios-and-catalyst.conf --prefix=$OUTPUT_PATH >> $LOG 2>&1
    make >> $LOG 2>&1
    make install >> $LOG 2>&1

    popd > /dev/null
done

echo "Creating the universal library for iOS"

OUTPUT_PATH=$ROOT_PATH/build/openssl/lib
rm -rf $OUTPUT_PATH
mkdir -p $OUTPUT_PATH
lipo -create \
    $ROOT_PATH/build/openssl/ios/lib/libcrypto.a \
    $ROOT_PATH/build/openssl/ios64/lib/libcrypto.a \
    -output $OUTPUT_PATH/libcrypto.a
lipo -create \
    $ROOT_PATH/build/openssl/ios/lib/libssl.a \
    $ROOT_PATH/build/openssl/ios64/lib/libssl.a \
    -output $OUTPUT_PATH/libssl.a

echo "Creating the OpenSSL XCFrameworks"

LIB_PATH=$ROOT_PATH/lib
LIBCRYPTO_PATH=$LIB_PATH/libcrypto/libcrypto.xcframework
LIBSSL_PATH=$LIB_PATH/libssl/libssl.xcframework
rm -rf $LIBCRYPTO_PATH
rm -rf $LIBSSL_PATH
mkdir -p $LIB_PATH

xcodebuild -create-xcframework \
    -library $ROOT_PATH/build/openssl/lib/libcrypto.a \
    -library $ROOT_PATH/build/openssl/iossimulator/lib/libcrypto.a \
    -library $ROOT_PATH/build/openssl/catalyst/lib/libcrypto.a \
    -library $ROOT_PATH/build/openssl/catalyst-arm/lib/libcrypto.a \
    -output $LIBCRYPTO_PATH

xcodebuild -create-xcframework \
    -library $ROOT_PATH/build/openssl/lib/libssl.a \
    -headers $ROOT_PATH/build/openssl/ios/include \
    -library $ROOT_PATH/build/openssl/iossimulator/lib/libssl.a \
    -headers $ROOT_PATH/build/openssl/iossimulator/include \
    -library $ROOT_PATH/build/openssl/catalyst/lib/libssl.a \
    -headers $ROOT_PATH/build/openssl/catalyst/include \
    -library $ROOT_PATH/build/openssl/catalyst-arm/lib/libssl.a \
    -headers $ROOT_PATH/build/openssl/catalyst-arm/include \
    -output $LIBSSL_PATH

pushd $LIB_PATH/libcrypto > /dev/null
zip -r ../libcrypto.zip .
popd > /dev/null

pushd $LIB_PATH/libssl > /dev/null
zip -r ../libssl.zip .
popd > /dev/null

echo "Done; cleaning up"
rm -rf /tmp/openssl
