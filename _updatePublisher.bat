@ECHO OFF

SETLOCAL

SET dlurl=https://github.com/HL7/fhir-ig-publisher/releases/latest/download/publisher.jar
SET publisher_jar=publisher.jar
SET input_cache_path=%CD%\input-cache\
SET skipPrompts=false

SET scriptdlroot=https://raw.githubusercontent.com/HL7/ig-publisher-scripts/main
SET update_bat_url=%scriptdlroot%/_updatePublisher.bat
SET gen_bat_url=%scriptdlroot%/_genonce.bat
SET gencont_bat_url=%scriptdlroot%/_gencontinuous.bat
SET gencont_sh_url=%scriptdlroot%/_gencontinuous.sh
SET gen_sh_url=%scriptdlroot%/_genonce.sh
SET update_sh_url=%scriptdlroot%/_updatePublisher.sh

IF "%~1"=="/f" SET skipPrompts=y


ECHO.
ECHO Checking internet connection...
PING tx.fhir.org -4 -n 1 -w 1000 | FINDSTR TTL && GOTO isonline
ECHO We're offline, nothing to do...
GOTO end

:isonline
ECHO We're online


:processflags
SET ARG=%1
IF DEFINED ARG (
	IF "%ARG%"=="-f" SET FORCE=true
	IF "%ARG%"=="--force" SET FORCE=true
	SHIFT
	GOTO processflags
)

FOR %%x IN ("%CD%") DO SET upper_path=%%~dpx

ECHO.
IF NOT EXIST "%input_cache_path%%publisher_jar%" (
	IF NOT EXIST "%upper_path%%publisher_jar%" (
		SET jarlocation="%input_cache_path%%publisher_jar%"
		SET jarlocationname=Input Cache
		ECHO IG Publisher is not yet in input-cache or parent folder.
		REM we don't use jarlocation below because it will be empty because we're in a bracketed if statement
		GOTO create
	) ELSE (
		ECHO IG Publisher FOUND in parent folder
		SET jarlocation="%upper_path%%publisher_jar%"
		SET jarlocationname=Parent folder
		GOTO upgrade
	)
) ELSE (
	ECHO IG Publisher FOUND in input-cache
	SET jarlocation="%input_cache_path%%publisher_jar%"
	SET jarlocationname=Input Cache
	GOTO upgrade
)

:create
IF DEFINED FORCE (
	MKDIR "%input_cache_path%" 2> NUL
	GOTO download
)

IF "%skipPrompts%"=="y" (
	SET create=Y
) ELSE (
	SET /p create="Ok? (Y/N) "
)
IF /I "%create%"=="Y" (
	ECHO Will place publisher jar here: %input_cache_path%%publisher_jar%
	MKDIR "%input_cache_path%" 2> NUL
	GOTO download
)
GOTO done

:upgrade
IF "%skipPrompts%"=="y" (
	SET overwrite=Y
) ELSE (
	SET /p overwrite="Overwrite %jarlocation%? (Y/N) "
)

IF /I "%overwrite%"=="Y" (
	GOTO download
)
GOTO done

:download
ECHO Downloading most recent publisher to %jarlocationname% - it's ~100 MB, so this may take a bit

FOR /f "tokens=4-5 delims=. " %%i IN ('ver') DO SET VERSION=%%i.%%j
IF "%version%" == "10.0" GOTO win10
IF "%version%" == "6.3" GOTO win8.1
IF "%version%" == "6.2" GOTO win8
IF "%version%" == "6.1" GOTO win7
IF "%version%" == "6.0" GOTO vista

ECHO Unrecognized version: %version%
GOTO done

:win10
CALL POWERSHELL -command if ('System.Net.WebClient' -as [type]) {(new-object System.Net.WebClient).DownloadFile(\"%dlurl%\",\"%jarlocation%\") } else { Invoke-WebRequest -Uri "%dlurl%" -Outfile "%jarlocation%" }

GOTO done

:win7
rem this may be triggering the antivirus - bitsadmin.exe is a known threat
rem CALL bitsadmin /transfer GetPublisher /download /priority normal "%dlurl%" "%jarlocation%"

rem this didn't work in win 10
rem CALL Start-BitsTransfer /priority normal "%dlurl%" "%jarlocation%"

rem this should work - untested
call (New-Object Net.WebClient).DownloadFile('%dlurl%', '%jarlocation%')
GOTO done

:win8.1
:win8
:vista
GOTO done



:done




ECHO.
ECHO Updating scripts
IF "%skipPrompts%"=="y" (
	SET updateScripts=Y
) ELSE (
	SET /p updateScripts="Update scripts? (Y/N) "
)
IF /I "%updateScripts%"=="Y" (
	GOTO scripts
)
GOTO end


:scripts

REM Download all batch files (and this one with a new name)

SETLOCAL DisableDelayedExpansion



:dl_script_1
ECHO Updating _updatePublisher.sh
call POWERSHELL -command if ('System.Net.WebClient' -as [type]) {(new-object System.Net.WebClient).DownloadFile(\"%update_sh_url%\",\"_updatePublisher.new.sh\") } else { Invoke-WebRequest -Uri "%update_sh_url%" -Outfile "_updatePublisher.new.sh" }
if %ERRORLEVEL% == 0 goto upd_script_1
echo "Errors encountered during download: %errorlevel%"
goto dl_script_2
:upd_script_1
start copy /y "_updatePublisher.new.sh" "_updatePublisher.sh" ^&^& del "_updatePublisher.new.sh" ^&^& exit


:dl_script_2
ECHO Updating _genonce.bat
call POWERSHELL -command if ('System.Net.WebClient' -as [type]) {(new-object System.Net.WebClient).DownloadFile(\"%gen_bat_url%\",\"_genonce.new.bat\") } else { Invoke-WebRequest -Uri "%gen_bat_url%" -Outfile "_genonce.bat" }
if %ERRORLEVEL% == 0 goto upd_script_2
echo "Errors encountered during download: %errorlevel%"
goto dl_script_3
:upd_script_2
start copy /y "_genonce.new.bat" "_genonce.bat" ^&^& del "_genonce.new.bat" ^&^& exit

:dl_script_3
ECHO Updating _gencontinuous.bat
call POWERSHELL -command if ('System.Net.WebClient' -as [type]) {(new-object System.Net.WebClient).DownloadFile(\"%gencont_bat_url%\",\"_gencontinuous.new.bat\") } else { Invoke-WebRequest -Uri "%gencont_bat_url%" -Outfile "_gencontinuous.bat" }
if %ERRORLEVEL% == 0 goto upd_script_3
echo "Errors encountered during download: %errorlevel%"
goto dl_script_4
:upd_script_3
start copy /y "_gencontinuous.new.bat" "_gencontinuous.bat" ^&^& del "_gencontinuous.new.bat" ^&^& exit


:dl_script_4
ECHO Updating _genonce.sh
call POWERSHELL -command if ('System.Net.WebClient' -as [type]) {(new-object System.Net.WebClient).DownloadFile(\"%gen_sh_url%\",\"_genonce.new.sh\") } else { Invoke-WebRequest -Uri "%gen_sh_url%" -Outfile "_genonce.sh" }
if %ERRORLEVEL% == 0 goto upd_script_4
echo "Errors encountered during download: %errorlevel%"
goto dl_script_5
:upd_script_4
start copy /y "_genonce.new.sh" "_genonce.sh" ^&^& del "_genonce.new.sh" ^&^& exit

:dl_script_5
ECHO Updating _gencontinuous.sh
call POWERSHELL -command if ('System.Net.WebClient' -as [type]) {(new-object System.Net.WebClient).DownloadFile(\"%gencont_sh_url%\",\"_gencontinuous.new.sh\") } else { Invoke-WebRequest -Uri "%gencont_sh_url%" -Outfile "_gencontinuous.sh" }
if %ERRORLEVEL% == 0 goto upd_script_5
echo "Errors encountered during download: %errorlevel%"
goto dl_script_6
:upd_script_5
start copy /y "_gencontinuous.new.sh" "_gencontinuous.sh" ^&^& del "_gencontinuous.new.sh" ^&^& exit



:dl_script_6
ECHO Updating _updatePublisher.bat
call POWERSHELL -command if ('System.Net.WebClient' -as [type]) {(new-object System.Net.WebClient).DownloadFile(\"%update_bat_url%\",\"_updatePublisher.new.bat\") } else { Invoke-WebRequest -Uri "%update_bat_url%" -Outfile "_updatePublisher.new.bat" }
if %ERRORLEVEL% == 0 goto upd_script_6
echo "Errors encountered during download: %errorlevel%"
goto end
:upd_script_6
start copy /y "_updatePublisher.new.bat" "_updatePublisher.bat" ^&^& del "_updatePublisher.new.bat" ^&^& exit


:end


IF "%skipPrompts%"=="true" (
  PAUSE
)
