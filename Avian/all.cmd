@echo off

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
echo Mode: %mode%

REM Perform actions requested
set PATH=%cygwin_usr_bin%;%cygwin_usr_sbin%;%cygwin_usr_local_bin%;%PATH%
if "%3"=="build" (
	make -C %avian_cygpath% platform=wp8 arch=%arch% mode=%mode%
) else if "%3"=="rebuild" (
	make -C %avian_cygpath% platform=wp8 arch=%arch% mode=%mode% clean
	make -C %avian_cygpath% platform=wp8 arch=%arch% mode=%mode%
) else if "%3"=="clean" (
	make -C %avian_cygpath% platform=wp8 arch=%arch% mode=%mode% clean
) else (
	echo Invalid command: %3
	exit /b -1
)