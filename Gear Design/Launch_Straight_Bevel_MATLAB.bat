@echo off
title Straight Bevel Gear MATLAB Design Launcher
cd /d "%~dp0\Matlab_Straight_Bevel"
echo ======================================================================
echo  STARTING STRAIGHT BEVEL GEAR MATLAB SUITE
echo  Wind Turbine Pitch Control System (90 deg Orthogonal Multi-Pinion)
echo ======================================================================
echo.
echo Launching MATLAB and running straight_bevel_gear_design.m...
matlab -nosplash -r "addpath(pwd); straight_bevel_gear_design;"
