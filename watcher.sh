#!/bin/bash   
# @see https://stackoverflow.com/a/53463162/2395062
cecho() {
    RED="\033[0;31m"
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    NC='\033[0m' # No Color
    # https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/reference/ASLR_cmds.html#//apple_ref/doc/uid/TP40000983-CH216-SW224
    osascript -e 'display notification "🎉 Build finished!!!" with title "HaxeFlixel" sound name "Ping"'
    printf "${!1}${2} ${NC}\n"
}

echo "🔨  Building game!!!"
lime build html5 -debug 
cecho "GREEN" "🎉  Build finished!!!"
# watchman-make -p 'source/*.hx' 'assets/data/*.tmx' -r 'sh watcher.sh'
# http-server export/html5/bin