@ECHO OFF
REM Attempts to locate VirtualDub.
REM Don't modify this file directly, instead create a "setenv.bat" file that
REM sets VDUB_HOME to your VirtualDub install or set the VDUB_HOME environment
REM variable globally. Note that we always invoke setenv.bat if it exists:

IF EXIST "%CD%\setenv.bat" CALL "%CD%\setenv.bat"

REM So this will overwrite any globally set environment variable. (This is done
REM to allow setenv.bat to also set any other necessary local environment
REM variables or do whatever else is requried.)

REM Check to see if we have VD now:

IF EXIST "%VDUB_HOME%\VirtualDub.exe" GOTO HaveVD

REM Otherwise, see if it's installed in Program Files:

REM We always want the 32-bit version, so if we're 64-bit, use %ProgramFiles(x86)%:
REM (I hate you, SET):
IF %PROCESSOR_ARCHITECTURE%==AMD64 SET VDUB_HOME=%ProgramFiles(x86)%\VirtualDub
IF NOT %PROCESSOR_ARCHITECTURE%==AMD64 SET VDUB_HOME=%ProgramFiles%\VirtualDub

REM Now see if that worked:
IF EXIST "%VDUB_HOME%\VirtualDub.exe" GOTO HaveVD

ECHO VirtualDub was not located. Please install the 32-bit version of VirtualDub
ECHO into the following path: %VDUB_HOME%
ECHO.
ECHO Or, if you have VirtualDub installed somewhere else, set the VDUB_HOME variable
ECHO to this alternate directory.

EXIT /B 1

:HaveVD
