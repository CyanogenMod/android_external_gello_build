# Copyright (C) 2015 The CyanogenMod Project
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
LOCAL_PATH := $(call my-dir)

# Maven Release Upload
# ===========================================================
include $(CLEAR_VARS)

LOCAL_MODULE := Gello_prebuilt
LOCAL_MODULE_CLASS := APPS
LOCAL_MODULE_TAGS := optional
LOCAL_CERTIFICATE := $(DEFAULT_SYSTEM_DEV_CERTIFICATE)

#Optional copy to local path, we'll build the module, copy it here, and publish from here.
LOCAL_MAVEN_ARTIFACT_PATH := $(LOCAL_PATH)/Gello.apk

#Remote details
LOCAL_MAVEN_REPO_ID := remote-repository
LOCAL_MAVEN_REPO := https://oss.sonatype.org/service/local/release/deploy/maven2
LOCAL_MAVEN_CLASSIFICATION := $(VARIANT)Release

LOCAL_MAVEN_GROUP := org.cyanogenmod
LOCAL_MAVEN_ARTIFACT := Gello
LOCAL_MAVEN_VERSION := 6.2.4
#LOCAL_MAVEN_CLASSIFIER := $(VARIANT)RealRelease
LOCAL_MAVEN_PACKAGING := apk
include vendor/cm/build/core/maven_artifact.mk
#include $(BUILD_MAVEN_PREBUILT)

#This is the target module to compile prior to publish
LOCAL_MAVEN_TARGET_MODULE := Gello_prebuilt.apk

#LOCAL_MAVEN_POM := $(LOCAL_PATH)/pom.xml

#$(LOCAL_MODULE): $(copied_jar)
#include $(PUBLISH_MAVEN_PREBUILT)
