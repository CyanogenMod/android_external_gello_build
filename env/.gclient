solutions = [
  { "name"        : "src",
    "url"         : "git://codeaurora.org/quic/chrome4sdp/chromium/src.git@refs/remotes/origin/m42",
    "deps_file"   : "DEPS",
    "managed"     : True,
    "safesync_url": "",
    "custom_deps" : {
        "src/swe/browser" : "https://github.com/CyanogenMod/android_packages_apps_gello.git@refs/remotes/origin/cm-13.0"
    }
  },
]
target_os = ["android"]
