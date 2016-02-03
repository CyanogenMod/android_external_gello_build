# TODO:--local is for tesing, remove it before ship
bash $1/gello_build.sh --local 2>&1 | tee log.log &>/dev/null
echo "Gello.apk"
