#!/bin/bash
#
#  Copyright (C) 2016 The CyanogenMod Project
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
#  Integrated SWE Build System for Gello
#

##
# Variables
#
TOP_GELLO=$(pwd)
SRC_GELLO=$TOP_GELLO/env/src

READY_APK=$TOP_GELLO/Gello.apk


##
# Flag Booleans
#
FAST=false
PUSH=false
NOSYNC=false
VERBOSE=false


##
# Sync
#
function sync() {
    if [ "$NOSYNC" != true ]; then
        cd $TOP_GELLO/env

        # If we have previously downloaded depot tools using this script
        # export its path for us
        if [ -d "$TOP_GELLO/depot/depot_tools" ]; then
            export PATH=$PATH:$TOP_GELLO/depot/depot_tools
        fi

        echo "Syncing now!"
        gclient sync -n --no-nag-max -j16
        return $?
    else
        return 0
    fi
}


##
# Setup
#
function setup() {
    local DONE_FILE=$TOP_GELLO/.cm_done
    local GOOGLE_SDK=$SRC_GELLO/third_party/android_tools/sdk/extras/google/google_play_services

    cd $SRC_GELLO

    if [ ! -f $DONE_FILE ]; then
        touch $DONE_FILE
    fi

    . build/android/envsetup.sh

    if [ "$FAST" != true ] && [ -f $DONE_FILE ]; then
        # !! The first time it asks a manual input to accept licenses !!
        GYP_DEFINES="$GYP_DEFINES OS=android swe_channel=cm" gclient runhooks
        return $?
    else
        return 0
    fi

    # If we don't have Google SDKs, get them
    # !! This asks a manual input to accept licenses !!
    if [ ! -d $GOOGLE_SDK ]; then
        bash $SRC_GELLO/build/install-android-sdks.sh
    fi


}


##
# Compile
#
function compile() {
    local TMP_APK=$SRC_GELLO/out/Release/apks/SWE_AndroidBrowser.apk
    local OUT_TARGET=$TOP_GELLO/Gello.apk

    cd $SRC_GELLO

    # Gello "shell" builds only if we have WITH_GELLO_SOURCE == true ,
    # this script is running, so it should already be true
    # if we're just doing tests we may have not that as true, set it
    # otherwise it won't hurt

    if [ "$WITH_GELLO_SOURCE" != true ]; then
        WITH_GELLO_SOURCE=true
    fi

    # Make things
    ninja -C out/Release swe_android_browser_apk

    if [ "$?" == 0 ]; then
        if [ -f "$OUT_TARGET" ]; then
            rm -f $OUT_TARGET
        fi
        cp $TMP_APK $OUT_TARGET
        return $?
    else
        return $?
    fi
}


##
# Check Flags
#
function checkflags() {
    if [ "$1" == "--verbose" ] || [ "$2" == "--verbose" ] ||
       [ "$3" == "--verbose" ] || [ "$4" == "--verbose" ]; then
        VERBOSE=true
    fi

    if [ "$1" == "--fast" ] || [ "$2" == "--fast" ] ||
       [ "$3" == "--fast" ] || [ "$4" == "--fast" ]; then
        NOSYNC=true
        FAST=true
    fi

    if [ "$1" == "--no-sync" ] || [ "$2" == "--no-sync" ] ||
       [ "$3" == "--no-sync" ] || [ "$4" == "--no-sync" ]; then
        NOSYNC=true
    fi

    if [ "$1" == "--push" ] || [ "$2" == "--push" ] ||
       [ "$3" == "--push" ] || [ "$4" == "--push" ]; then
        PUSH=true
    fi
}


##
# Help
#
function helpgello() {
    cat<<EOF
Gello inline build system (c) CyanogenMod 2016
Usage: ./gello_build.sh <flags>
flags:
    -h            = Show this message
    -v            = Verbose mode, show more details
    --depot       = Install Depot Tool
    --fast        = Skip sync and runhooks, useful for testing changes
    --push        = Once everything else is done, install the given apk on a connected device
    --no-sync     = Skip sync
EOF
}


##
# Depot
#
function getdepot() {
    cd $TOP_GELLO

    mkdir depot
    cd depot
    git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git depot
}


##
# Main
#

if [ "$1" == "--depot" ]; then
    getdepot && exit 0
elif [ "$1" == "--help" ]; then
    helpgello && exit 0
fi

checkflags $1 $2 $3 $4

sync && setup && compile

if [ "$?" == 0 ]; then
    echo "$(tput setaf 2)Done! Gello: $READY_APK$(tput sgr reset)"

    if [ "$PUSH" == true ]; then
        if [ ! -x $(which adb) ]; then
            adb wait-for-device
            adb install -r -d $TOP_GELLO/Gello.apk
            exit $?
        else
            echo "Adb not found! Unable to push gello to device!"
            exit 3
        fi
    fi

    exit 0
fi
