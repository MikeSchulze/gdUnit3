@ECHO OFF
CLS

IF NOT DEFINED GODOT_BIN (
	ECHO "GODOT_BIN is not set."
	ECHO "Please set the environment variable 'setx GODOT_BIN <path to godot.exe>'"
	EXIT /b -1
)

REM scan if Godot mono used and compile c# classes
for /f "tokens=5 delims=. " %%i in ('%GODOT_BIN% --version') do set GODOT_TYPE=%%i
IF "%GODOT_TYPE%" == "mono" (
	ECHO "Godot mono detected"
	ECHO Compiling c# classes ... Please Wait
	%GODOT_BIN% --build-solutions --no-window -q --quiet
	ECHO done
)

%GODOT_BIN% --no-window -s -d .\addons\gdUnit3\bin\GdUnitCmdTool.gd %*
SET exit_code=%errorlevel%
%GODOT_BIN% --no-window --quiet -s -d .\addons\gdUnit3\bin\GdUnitCopyLog.gd %*

ECHO %exit_code%

EXIT /B %exit_code%
