@echo off
title Dependency Installer and File Association Setter

:: =================================
:: 1. CHECK FOR PYTHON
:: =================================
echo [1/3] Checking for Python and its path...
:: The 'where' command finds the location of an executable in the PATH.
:: We capture the first result into the PYTHON_PATH variable.
for /f "delims=" %%i in ('where python') do (
    set "PYTHON_PATH=%%i"
    goto python_found
)

:: This part runs only if the 'for' loop finds nothing.
echo.
echo [ERROR] Python is not installed or not in your PATH.
echo Please install Python from the Microsoft Store or python.org and try again.
echo Make sure to check "Add Python to PATH" during installation.
pause
exit /b

:python_found
echo      Python found at: %PYTHON_PATH%
echo.

:: =================================
:: 2. SET FILE ASSOCIATION
:: =================================
echo [2/3] Setting .py file association...
:: 'assoc' links a file extension (.py) to a file type name (Python.File).
assoc .py=Python.File >nul
:: 'ftype' defines the command to run for that file type.
:: "%PYTHON_PATH%" is the full path to python.exe we found earlier.
:: "%1" is a placeholder for the script file you double-click.
:: %* is a placeholder for any arguments passed to the script.
ftype Python.File="%PYTHON_PATH%" "%1" %* >nul
echo      Successfully associated .py files to run with the Python interpreter.
echo.

:: =================================
:: 3. CHECK FOR PLATFORM TOOLS
:: =================================
echo [3/3] Checking for Android Platform Tools (ADB/Fastboot)...
if exist "platform-tools\adb.exe" (
    echo      Platform Tools already exist.
    goto end
)

echo      Platform Tools not found. Attempting to download...
echo.

:: Use PowerShell to download and extract the tools
powershell -NoProfile -ExecutionPolicy Bypass -Command "Write-Host 'Downloading platform-tools.zip...'; Invoke-WebRequest -Uri 'https://dl.google.com/android/repository/platform-tools-latest-windows.zip' -OutFile 'platform-tools.zip'; Write-Host 'Extracting...'; Expand-Archive -Path 'platform-tools.zip' -DestinationPath '.' -Force; Write-Host 'Cleaning up...'; Remove-Item 'platform-tools.zip'"

if exist "platform-tools\adb.exe" (
    echo.
    echo      Platform Tools downloaded and extracted successfully.
) else (
    echo.
    echo [ERROR] Failed to download or extract Platform Tools.
    echo Please check your internet connection or download them manually.
    pause
    exit /b
)

:end
echo.
echo =======================================================
echo  Setup complete!
echo  - .py files are now set to run when double-clicked.
echo  - Dependencies are installed.
echo  You can now run installer.py
echo =======================================================
echo.
pause