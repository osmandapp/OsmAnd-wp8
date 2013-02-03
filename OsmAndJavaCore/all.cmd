@echo off

REM Detect output location
set output=%3
for /F "tokens=*" %%i in ('cygpath -u %output%') do set output_cygpath=%%i
echo Output: %output%

REM Detect OsmAnd JAVA location
set osmand=%~dp0..\..\core\OsmAnd-java

REM Detect avian location
set avian=%~dp0..\..\avian\core
echo Avian: %avian%
for /F "tokens=*" %%i in ('cygpath -u %avian%') do set avian_cygpath=%%i

REM Get cygwin path
for /F "tokens=*" %%i in ('cygpath -w /usr/bin') do set cygwin_usr_bin=%%i
for /F "tokens=*" %%i in ('cygpath -w /usr/sbin') do set cygwin_usr_sbin=%%i
for /F "tokens=*" %%i in ('cygpath -w /usr/local/bin') do set cygwin_usr_local_bin=%%i

REM Detect avian-compatible architecture
if "%1"=="x86" (
	set arch=i386
) else if "%1"=="ARM" (
	set arch=arm
) else (
	echo Invalid target: %1
	exit /b -1
)
echo Architecture: %arch%

REM Detect avian-compatible build mode
if "%2"=="Debug" (
	set mode=debug
) else if "%2"=="Release" (
	set mode=fast
) else (
	echo Invalid configuration: %2
	exit /b -1
)

REM Perform actions requested
set PATH=%cygwin_usr_bin%;%cygwin_usr_sbin%;%cygwin_usr_local_bin%;%PATH%
if "%4"=="build" (
	bash all.sh "%output_cygpath%" %arch% %mode% build
) else if "%4"=="clean" (
	bash all.sh "%output_cygpath%" %arch% %mode% clean
) else if "%4"=="rebuild" (
	bash all.sh "%output_cygpath%" %arch% %mode% clean
	bash all.sh "%output_cygpath%" %arch% %mode% build
) else (
	echo Invalid command: %4
	exit /b -1
)