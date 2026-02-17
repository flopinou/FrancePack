@echo off
setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
set "VERSION=1.30.0"
set "CITIES=PAR LYS MRS LIL TLS RNS"
set "URL=https://github.com/protomaps/go-pmtiles/releases/download/v%VERSION%/go-pmtiles_%VERSION%_Windows_x86_64.zip"

:: Copy city data files
for %%C in (%CITIES%) do (
    set "SOURCE=%SCRIPT_DIR%data\%%C"
    set "TARGET=%SCRIPT_DIR%..\..\cities\data\%%C"
    
    if exist "!SOURCE!" (
        echo [FrancePack] Copying data files for %%C...
        if not exist "!TARGET!" mkdir "!TARGET!"
        copy /Y "!SOURCE!\*" "!TARGET!\" >nul
    ) else (
        echo [FrancePack] Warning: Source folder for %%C not found.
    )
)

echo [FrancePack] All data files copied successfully.

:: Check for pmtiles binary and download if missing

if exist "%SCRIPT_DIR%pmtiles.exe" (
    echo [FrancePack] pmtiles.exe already exists.
    goto :start_server
)

echo [FrancePack] 'pmtiles.exe' not found.

set "DOWNLOAD_SUCCESS=0"

:: Try curl and tar
where curl >nul 2>nul
if !errorlevel! equ 0 (
    where tar >nul 2>nul
    if !errorlevel! equ 0 (
        echo [FrancePack] Method 1: Attempting download via Curl and Tar...
        
        curl -L -f -o "%SCRIPT_DIR%pmtiles.zip" "!URL!"
        
        if exist "%SCRIPT_DIR%pmtiles.zip" (
            echo [FrancePack] Extracting via Tar...
            tar -xf "%SCRIPT_DIR%pmtiles.zip" -C "%SCRIPT_DIR%"
            
            if exist "%SCRIPT_DIR%pmtiles.exe" (
                set "DOWNLOAD_SUCCESS=1"
                del "%SCRIPT_DIR%pmtiles.zip"
                echo [FrancePack] Download and extraction successful via Curl/Tar.
            )
        )
    )
)

:: Powershell fallback
if "!DOWNLOAD_SUCCESS!"=="0" (
    echo [FrancePack] Method 1 failed or tools missing. Falling back to PowerShell...
    
    if exist "%SCRIPT_DIR%pmtiles.zip" del "%SCRIPT_DIR%pmtiles.zip"

    echo [FrancePack] Downloading via PowerShell...
    powershell -Command "Invoke-WebRequest -Uri '!URL!' -OutFile '%SCRIPT_DIR%pmtiles.zip'"
    
    if exist "%SCRIPT_DIR%pmtiles.zip" (
        echo [FrancePack] Extracting via PowerShell...
        powershell -Command "Expand-Archive -Path '%SCRIPT_DIR%pmtiles.zip' -DestinationPath '%SCRIPT_DIR%' -Force"
        del "%SCRIPT_DIR%pmtiles.zip"
        
        if exist "%SCRIPT_DIR%pmtiles.exe" (
            set "DOWNLOAD_SUCCESS=1"
            echo [FrancePack] Download and extraction successful via PowerShell.
        )
    )
)

if not exist "%SCRIPT_DIR%pmtiles.exe" (
    echo [FrancePack] Error: Failed to download pmtiles.exe using both methods.
    echo [FrancePack] Please download it manually from: !URL!
    pause
    exit /b 1
)

:: Start tile server
:start_server
echo [FrancePack] Starting tile server on port 8080...
echo [FrancePack] Keep this window open while playing!
"%SCRIPT_DIR%pmtiles.exe" serve "%SCRIPT_DIR%." --port 8080 --cors=*

pause