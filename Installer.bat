@echo off
title Rom Flasher
color 0A
setlocal EnableDelayedExpansion

:: ============================
:: ROM FLASHER START
:: ============================
echo =============================
echo         ROM FLASHER
echo =============================
echo.
echo Device: Tecno Spark 30C (KL8H)
echo Rom: Rom Version
echo Android version: Android Version
echo Build Date: Build Date
echo Developer: Ayu Kashyap - @dev_ayu
echo.
echo ^>^> Allow the ADB popup on your phone if prompted.
pause

echo.
<nul set /p=^>^> Rebooting to Fastboot Mode...
adb reboot fastboot >nul 2>&1
call :dots

echo.
<nul set /p=^>^> Formatting data...
fastboot -w >nul 2>&1
call :dots

echo.
<nul set /p=^>^> Erasing system...
fastboot erase system >nul 2>&1
call :dots

<nul set /p=^>^> Deleting product_cow...
fastboot delete-logical-partition product_cow >nul 2>&1
call :dots

<nul set /p=^>^> Deleting product_a...
fastboot delete-logical-partition product_a >nul 2>&1
call :dots

<nul set /p=^>^> Deleting product...
fastboot delete-logical-partition product >nul 2>&1
call :dots

<nul set /p=^>^> Deleting system_ext...
fastboot delete-logical-partition system_ext >nul 2>&1
call :dots

<nul set /p=^>^> Deleting system_ext_a...
fastboot delete-logical-partition system_ext_a >nul 2>&1
call :dots

echo.
<nul set /p=^>^> Flashing system image...
fastboot flash system images\system.img >nul 2>&1
call :dots

echo.
echo ^>^> ROM flashed successfully.

:: ============================
:: Root / Unroot Selection Loop
:: ============================
:choose_root
echo.
echo Select boot method:
echo [1] Magisk
echo [2] Apatch
echo [3] Unroot (Stock Boot)
set /p choice="Enter choice (1/2/3): "

if "%choice%"=="1" goto magisk
if "%choice%"=="2" goto apatch
if "%choice%"=="3" goto unroot
echo Invalid choice. Please enter 1, 2, or 3.
goto choose_root

:magisk
echo.
<nul set /p=^>^> Installing Magisk...
fastboot flash boot images\boot_5.15.188.img >nul 2>&1
fastboot reboot bootloader >nul 2>&1
fastboot flash init_boot_a images\init_boot_a_magisk.img >nul 2>&1
fastboot --disable-verity --disable-verification flash vbmeta_a images\vbmeta_a.img >nul 2>&1
fastboot --disable-verity --disable-verification flash vbmeta_system_a images\vbmeta_system_a.img >nul 2>&1
call :dots
echo ^>^> Magisk installed successfully.
goto reboot

:apatch
echo.
<nul set /p=^>^> Installing Apatch...
fastboot flash boot images\boot_5.15.188_apatch.img >nul 2>&1
fastboot reboot bootloader >nul 2>&1
fastboot flash init_boot_a images\init_boot_a.img >nul 2>&1
fastboot --disable-verity --disable-verification flash vbmeta_a images\vbmeta_a.img >nul 2>&1
fastboot --disable-verity --disable-verification flash vbmeta_system_a images\vbmeta_system_a.img >nul 2>&1
call :dots
echo ^>^> Apatch installed successfully.
goto reboot

:unroot
echo.
<nul set /p=^>^> Flashing stock boot (Unroot)...
    fastboot flash boot images\boot_5.15.188.img >nul 2>&1
fastboot reboot bootloader >nul 2>&1
fastboot flash init_boot_a images\init_boot_a.img >nul 2>&1
fastboot --disable-verity --disable-verification flash vbmeta_a images\vbmeta_a.img >nul 2>&1
fastboot --disable-verity --disable-verification flash vbmeta_system_a images\vbmeta_system_a.img >nul 2>&1
call :dots
echo ^>^> Stock boot flashed (Unrooted).
goto reboot

:reboot
echo.
<nul set /p=^>^> Rebooting device now...
fastboot reboot >nul 2>&1
call :dots
echo.
pause
exit /b

:: ============================
:: Function: Animated Dots
:: ============================
:dots
setlocal EnableDelayedExpansion
for /L %%i in (1,1,3) do (
    <nul set /p=.
    timeout /nobreak /t 1 >nul
)
echo.
endlocal
goto :eof
