@echo off
title Zerol Bevel Gear MATLAB Suite Launcher
cd /d "%~dp0\Matlab_Zerol_Bevel"
echo ======================================================================
echo  STARTING ZEROL BEVEL GEAR MATLAB SUITE
echo  Wind Turbine Pitch Control System (Gleason Face-Milling & 3-Pinion Ring)
echo ======================================================================
echo.
echo Launching MATLAB GUI...
matlab -nosplash -r "addpath(pwd); zerol_bevel_gui;"
