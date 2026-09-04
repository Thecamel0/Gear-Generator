@echo off
title Spur Gear MATLAB Design Launcher
cd /d "%~dp0\Matlab_Spur"
echo ======================================================================
echo  STARTING SPUR GEAR MATLAB SUITE
echo  Wind Turbine Pitch Control System
echo ======================================================================
echo.
echo Launching MATLAB and running spur_gear_design.m...
matlab -nosplash -r "addpath(pwd); spur_gear_design;"
