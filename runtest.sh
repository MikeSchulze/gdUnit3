#!/bin/sh

if [ -z "$GODOT_BIN" ]; then
    echo "'GODOT_BIN' is not set."
    echo "Please set the environment variable  'export GODOT_BIN=/Applications/Godot.app/Contents/MacOS/Godot'"
    exit 1
fi

$GODOT_BIN --no-window -s -d ./addons/gdUnit3/bin/GdUnitCmdTool.gd $*
declare -i exit_code=$?
$GODOT_BIN --no-window --quiet -s -d ./addons/gdUnit3/bin/GdUnitCopyLog.gd $* > /dev/null
exit $exit_code
