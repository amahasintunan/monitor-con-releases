@echo off
REM
REM monitor-client.bat — Windows launcher for the Java Swing GUI monitor client.
REM
REM JAVA_HOME resolution order:
REM   1. %%JAVA_HOME%% from the environment (if set and the dir exists)
REM   2. java found on PATH (if it's JDK 21+)
REM   3. JAVA_HOME read from monitor_client.ini
REM   4. Error — ask the user to install JDK 21+ or edit the ini file.
REM
REM Usage:  monitor-client.bat -h localhost -p 2019 -P tcp

setlocal enabledelayedexpansion
cd /d "%~dp0"

set JAVA_CMD=

REM ── Step 1: %%JAVA_HOME%% from environment ────────────────────────────────────
if not "%JAVA_HOME%"=="" (
    if exist "%JAVA_HOME%\bin\java.exe" (
        set "JAVA_CMD=%JAVA_HOME%\bin\java.exe"
    )
)

REM ── Step 2: java on PATH ──────────────────────────────────────────────────────
if "%JAVA_CMD%"=="" (
    for /f "delims=" %%j in ('where java 2^>nul') do (
        set "JAVA_CMD=%%j"
        goto :found_java_path
    )
)
:found_java_path

REM ── Step 3: JAVA_HOME from ini file ───────────────────────────────────────────
if "%JAVA_CMD%"=="" (
    set INI_FILE=monitor_client.ini
    if exist "!INI_FILE!" (
        for /f "tokens=1,* delims==" %%a in (!INI_FILE!) do (
            if "%%a"=="JAVA_HOME" (
                if exist "%%b\bin\java.exe" (
                    set "JAVA_CMD=%%b\bin\java.exe"
                    goto :found_ini_java
                )
            )
        )
    )
)
:found_ini_java

REM ── Validate ──────────────────────────────────────────────────────────────────
if "%JAVA_CMD%"=="" (
    echo ERROR: Could not find JDK 21+.
    echo.
    echo Options:
    echo   1. Install JDK 21+ and add 'java' to your PATH
    echo   2. Set JAVA_HOME in your shell:  set JAVA_HOME=C:\path\to\jdk-21
    echo   3. Edit monitor_client.ini and set JAVA_HOME there
    echo.
    exit /b 1
)

echo Using: %JAVA_CMD%
for /f "tokens=*" %%v in ('"%JAVA_CMD%" -fullversion 2^>^&1') do echo %%v

REM ── JAR file ──────────────────────────────────────────────────────────────────
set JAR_FILE=monitor_client.jar
if not exist "%JAR_FILE%" (
    echo ERROR: %JAR_FILE% not found in %CD%
    echo Build it with:  mvn clean package
    exit /b 1
)

REM ── Launch ────────────────────────────────────────────────────────────────────
set LOOK_AND_FEEL=-Dswing.defaultlaf=javax.swing.plaf.nimbus.NimbusLookAndFeel
"%JAVA_CMD%" -Xms128m -Xmx128m %LOOK_AND_FEEL% -cp "%JAR_FILE%" monitor_client.MonitorClient %*
if %ERRORLEVEL% equ 127 (
    echo The specified JAVA path does not exist.
    exit /b 1
)
