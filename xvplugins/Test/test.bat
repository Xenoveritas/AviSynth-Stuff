@ECHO OFF

CALL find_vd.bat

REM Abort if not found:
IF NOT EXIST "%VDUB_HOME%\VirtualDub.exe" EXIT /B 1

SET AVS_FILE=%1
IF "%AVS_FILE%"=="" SET AVS_FILE=Test.avs

"%VDUB_HOME%\VirtualDub.exe" "%AVS_FILE%" > log.txt
