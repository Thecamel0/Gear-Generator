@echo off
title Wind Turbine Pitch Control System - MATLAB Launcher Menu
:menu
cls
echo ======================================================================
echo   WIND TURBINE PITCH CONTROL SYSTEM — MATLAB GEAR DESIGN SUITES
echo ======================================================================
echo.
echo   [1] Zerol Bevel Gear Interactive GUI (zerol_bevel_gui.m)
echo   [2] Zerol Bevel Gear Batch Script (zerol_bevel_design_v2.m)
echo   [3] Straight Bevel Gear Design (straight_bevel_gear_design.m)
echo   [4] Spiral Bevel Gear Design (spiral_bevel_gear_design.m)
echo   [5] External Spur Gear Design (spur_gear_design.m)
echo   [6] Internal Spur Ring Gear Design (internal_spur_gear_design.m)
echo   [7] Helical Gear Design (helical_gear_design.m)
echo   [8] Launch Web CAD Studio (Three.js Web App)
echo   [9] Exit
echo.
echo ======================================================================
set /p choice="Select an option (1-9): "

if "%choice%"=="1" goto zerol_gui
if "%choice%"=="2" goto zerol_batch
if "%choice%"=="3" goto straight_bevel
if "%choice%"=="4" goto spiral_bevel
if "%choice%"=="5" goto spur
if "%choice%"=="6" goto internal_spur
if "%choice%"=="7" goto helical
if "%choice%"=="8" goto web_app
if "%choice%"=="9" goto end

echo Invalid option. Please select 1-9.
pause
goto menu

:zerol_gui
call "%~dp0Gear Design\Launch_Zerol_Bevel_MATLAB.bat"
goto end

:zerol_batch
cd /d "%~dp0Gear Design\Matlab_Zerol_Bevel"
matlab -nosplash -r "addpath(pwd); zerol_bevel_design_v2;"
goto end

:straight_bevel
call "%~dp0Gear Design\Launch_Straight_Bevel_MATLAB.bat"
goto end

:spiral_bevel
call "%~dp0Gear Design\Launch_Spiral_Bevel_MATLAB.bat"
goto end

:spur
call "%~dp0Gear Design\Launch_Spur_MATLAB.bat"
goto end

:internal_spur
call "%~dp0Gear Design\Launch_Internal_Spur_MATLAB.bat"
goto end

:helical
call "%~dp0Gear Design\Launch_Helical_MATLAB.bat"
goto end

:web_app
call "%~dp0Launch_Web_Studio.bat"
goto end

:end
