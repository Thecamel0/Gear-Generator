@echo off
title Spiral Bevel Gear MATLAB Design Launcher
cd /d "%~dp0\Matlab_Spiral_Bevel"
echo ======================================================================
echo  STARTING SPIRAL BEVEL GEAR MATLAB SUITE
echo  Wind Turbine Pitch Control System (90 deg Orthogonal Multi-Pinion)
echo ======================================================================
echo.
echo Launching MATLAB and running spiral_bevel_gear_design.m...
matlab -nosplash -r "addpath(pwd); spiral_bevel_gear_design;"
pause
