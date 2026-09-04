@echo off
title Helical Gear MATLAB Design Launcher
cd /d "%~dp0\Matlab_Helical"
echo ======================================================================
echo  STARTING HELICAL GEAR MATLAB SUITE
echo  Wind Turbine Pitch Control System
echo ======================================================================
echo.
echo Launching MATLAB and running helical_gear_design.m...
matlab -nosplash -r "addpath(pwd); helical_gear_design;"
