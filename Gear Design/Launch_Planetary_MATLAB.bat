@echo off
title Planetary Gear MATLAB Design Launcher
cd /d "%~dp0\Matlab_Planetary"
echo ======================================================================
echo  STARTING PLANETARY GEAR MATLAB SUITE
echo  Wind Turbine Pitch Control System — Epicyclic Reducer (Sun, Planets, Ring, Carrier)
echo ======================================================================
echo.
echo Launching MATLAB and running planetary_gear_design.m...
matlab -nosplash -r "addpath(pwd); planetary_gear_design;"
