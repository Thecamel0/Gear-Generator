@echo off
title Gear Master Web Studio Launcher
cd /d "%~dp0Gear Design\Web_App"
echo ======================================================================
echo  STARTING GEAR MASTER — WEB CAD STUDIO (VITE + THREE.JS)
echo  Wind Turbine Pitch Control System & Custom Gear Design Suite
echo  Supports: Zerol Bevel, Straight Bevel, Spiral Bevel, Spur, Internal Ring, Helical
echo ======================================================================
echo.
echo Launching local development server and opening browser...
start http://localhost:5173
npm run dev
