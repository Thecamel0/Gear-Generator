@echo off
title Internal Spur Gear MATLAB Design Launcher
cd /d "%~dp0\Matlab_Internal_Spur"
echo ======================================================================
echo  STARTING INTERNAL SPUR GEAR MATLAB SUITE
echo  Wind Turbine Pitch Control System — Ring Gear & Pinion Drive
echo ======================================================================
echo.
echo Launching MATLAB and running internal_spur_gear_design.m...
matlab -nosplash -r "addpath(pwd); internal_spur_gear_design;"
