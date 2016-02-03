# Wrapper for gello build script

bash $1/gello_build.sh --fast 2>&1 | tee $1/lastbuild.log &>/dev/null
echo $?
