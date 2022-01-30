#!/usr/bin/env bash
echo $@
connfile="${@: -1}"
connfile=$(realpath "$connfile")
echo "conn file linux path: $connfile"

mkdir -p ~/.wine/drive_c/Windows/Temp/jupyter_runtime
cp $connfile ~/.wine/drive_c/Windows/Temp/jupyter_runtime

#connfile='C:\Windows\Temp\'$(basename "$connfile")
connfile=Z:${connfile//\//\\}

export JUPYTER_CONNECTION=$connfile
echo "conn file wine path: $JUPYTER_CONNECTION"
"${@: 1:${#@}-1}" 2>&1 | tee test.log