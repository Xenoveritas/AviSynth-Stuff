@ECHO OFF

CALL find_vd.bat

REM Abort if not found:
IF NOT EXIST "%VDUB_HOME%\VirtualDub.exe" EXIT /B 1

"%VDUB_HOME%\VirtualDub.exe" Test.avs > log.txt
