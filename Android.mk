#
# Copyright (C) 2016 The CyanogenMod Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Install the prebuilt gello apk.

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := Gello
LOCAL_MODULE_CLASS := APPS
LOCAL_CERTIFICATE := $(DEFAULT_SYSTEM_DEV_CERTIFICATE)

LOCAL_OVERRIDES_PACKAGES := Browser

ifeq ($(WITH_GELLO_SOURCE),true)
# Build from source
ifeq ($(LOCAL_GELLO),true)
BUILD_GELLO := $(info $(shell bash $(LOCAL_PATH)/gello_build.sh --local 1>&2))
else
BUILD_GELLO := $(info $(shell bash $(LOCAL_PATH)/gello_build.sh 1>&2))
endif
LOCAL_SRC_FILES := Gello.apk
else
LOCAL_SRC_FILES := ../../prebuilts/cm/Gello.apk
endif

include $(BUILD_PREBUILT)
