@echo off
title Zerol Bevel Gear MATLAB GUI Launcher
cd /d "%~dp0Gear Design\Matlab_Zerol_Bevel"
echo ======================================================================
echo  STARTING ZEROL BEVEL GEAR MATLAB GUI
echo  Wind Turbine Pitch Control System
echo ======================================================================
echo.
echo Launching MATLAB GUI...
matlab -nosplash -r "addpath(pwd); zerol_bevel_gui;"
