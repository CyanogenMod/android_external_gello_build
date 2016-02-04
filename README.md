Gello Build System
==================

Inline build environment for Gello

Documentation
-------------

Features
----------
- *--clean* = Make a clean build
- *--depot* = Install Depot Tool
- *--fast* = Skip sync and runhooks, useful for testing changes
- *--local* = Pick local gello from packages/apps/Gello (for testing purpose)
- *--push* = Once everything else is done, install the given apk on a connected device
- *--no-sync* = Skip sync

How to build
----------
If you're going to build from CyanogenMod build environment you will be able to choose between Sourcebuilt or Prebuilt. By default CyanogenMod uses Prebuilt to save you time, data and disk space.
If you don't want to use/trust prebuilt apk (that comes from CyanogenMod Maven) for some reason, you're free to build it yourself on your own machine. To build from source you just need to run the following commands:

    export WITH_GELLO_SOURCE=true
    mka Gello
To be able to build Gello you'll need to set up your machine, see [Setup](https://github.com/CyanogenMod/android_external_gello_build#setup).

Testing
----------
If you're working on the Gello shell (packages/apps/Gello), and you've sucessfully compiled at least once,
you may want to use your local Gello instead of remote one. By using the local one, you won't be
syncing other chromium / swe sources too.

    export WITH_GELLO_SOURCE=true
    export LOCAL_GELLO=true
    mka Gello

Setup
----------
Read [chromium documentation](https://chromium.googlesource.com/chromium/src/+/master/docs/linux_build_instructions_prerequisites.md) for needed packages to build Gello.
To get sources you need Depot tools that can be easily installed by running

    ./gello_build.sh --depot

During the first build you may be asked to accept EULA for some components needed to compile.
__Building from source is not recommend to those who have a really limited storage and / or data plan, the Gello environment needs to download a lot of data__
