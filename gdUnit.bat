@echo off
cls
SET GODOT_BIN=D:\develop\Godot_v3.2.4-beta3_win64.exe

ECHO %GODOT_BIN%

if not defined GODOT_BIN (
	echo "GODOT_BIN is not set."
	echo "Please set the environment variable 'SET GODOT_BIN=<path to godot.exe>'"
	exit /b -1
)

echo "test"

%GODOT_BIN% -s .\addons\gdUnit3\GdUnitCmdTool.gd --verbose

exit /b