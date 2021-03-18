@echo off
cls
SET GODOT_BIN=D:\develop\Godot.exe

ECHO %GODOT_BIN%

if not defined GODOT_BIN (
	echo "GODOT_BIN is not set."
	echo "Please set the environment variable 'SET GODOT_BIN=<path to godot.exe>'"
	exit /b -1
)

echo "test"

%GODOT_BIN% -s -d .\addons\gdUnit3\GdUnitCmdTool.gd %*

exit /b