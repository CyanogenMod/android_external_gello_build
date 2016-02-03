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

TOP_GELLO=$(pwd)


##
# Flag Booleans
#
FAST=false
PUSH=false
NOSYNC=false
CLEAN=false
LOCAL=false

##
# Sync
#
function sync() {
    # If we have previously downloaded depot tools using this script
    # export its path for us
    if [ -d "$TOP_GELLO/depot/depot_tools" ]; then
        export PATH=$PATH:$TOP_GELLO/depot/depot_tools
    fi

    if [ "$CLEAN" == true ]; then
        cd $TOP_GELLO/env

        echo "Cleaning..."

        # Clean out stuffs
        rm -rf $SRC_GELLO/out
        find $TOP_GELLO -name index.lock -exec rm {} \;
        gclient recurse git clean -fdx .

    fi

    if [ "$NOSYNC" != true ]; then
        cd $TOP_GELLO/env

        echo "Syncing now!"
        gclient sync -n --no-nag-max
        local SYNCRET=$?

        if [ "$CLEAN" == true ] && [ "$SYNCRET" == 0 ]; then
            gclient recurse git clean -fdx .
            return $?
        else
            return $SYNCRET
        fi
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
    local LOCAL_GELLO=$TOP_GELLO/../../packages/apps/Gello

    cd $SRC_GELLO

    if [ ! -f $DONE_FILE ]; then
        touch $DONE_FILE
    fi

    . build/android/envsetup.sh

    # If local is enabled we will be using local gello shell instead of synced one
    if [ "$LOCAL" == true ]; then
        if [ -d $LOCAL_GELLO ]; then
            if [ -d $BUILD_GELLO ]; then
                mv $BUILD_GELLO $BACKUP_GELLO
            fi
            cp -r $LOCAL_GELLO $BUILD_GELLO
        else
            echo "No local Gello found (excepted to be at $LOCAL_GELLO)"
            return 4
        fi
    fi

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

    # Gello "shell" builds only if we have GELLO_SRC == true ,
    # because we just wait it to build from here
    GELLO_SRC=true

    # Make things
    ninja -C out/Release swe_android_browser_apk
    local BUILDRET=$?

    if [ "$LOCAL" == true ]; then
        rm -rf $BUILD_GELLO
        mv $BACKUP_GELLO $BUILD_GELLO
    fi

    export GELLO_SRC=false

    if [ "$BUILDRET" == 0 ]; then
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
function parseflags() {
    for flag in "$@"
    do
        case "$flag" in
            --fast)
                NOSYNC=true
                FAST=true
                ;;
            --no-sync)
                NOSYNC=true
                ;;
            --push)
                PUSH=true
                ;;
            --clean)
                CLEAN=true
                ;;
            --local)
                NOSYNC=true
                LOCAL=true
                ;;
        esac
    done
}

##
# PathValidator
#
function pathvalidator() {
    local ENV_PATH=$TOP_GELLO/external/gello-build

    # Adjust path to make sure it works both from make and manual sh execution
    if [ ! -d "$TOP_GELLO/env/src" ]; then
        if [ -d "$ENV_PATH" ]; then
            TOP_GELLO=$ENV_PATH
        fi
    fi

    # Set up paths now
    SRC_GELLO=$TOP_GELLO/env/src
    BACKUP_GELLO=$SRC_GELLO/swe/browser_orig
    BUILD_GELLO=$SRC_GELLO/swe/browser
    READY_APK=$TOP_GELLO/Gello.apk
}


##
# Help
#
function helpgello() {
    cat<<EOF
Gello inline build system (c) CyanogenMod 2016
Usage: ./gello_build.sh <flags>
flags:
    --clean       = Make a clean build
    --depot       = Install Depot Tool
    --fast        = Skip sync and runhooks, useful for testing local changes
    --local       = Pick local gello from packages/apps/Gello (for testing purpose)
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
    git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
}

##
# Main
#
pathvalidator

if [ "$1" == "--depot" ]; then
    getdepot && exit 0
elif [ "$1" == "--help" ]; then
    helpgello && exit 0
fi

parseflags "$@"


sync && setup && compile

if [ "$?" == 0 ]; then
    echo "$(tput setaf 2)Done! Gello: $READY_APK$(tput sgr reset)"

    if [ "$PUSH" == true ]; then
        if [ -x $(which adb) ]; then
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
