@echo off
title Launch Internship Technical Presentation (.PPTX)
cd /d "%~dp0"

echo =====================================================================
echo  WIND TURBINE PITCH CONTROL SYSTEM - INTERNSHIP PRESENTATION (.PPTX)
echo  Candidate: Ahmed Majdy Ahmed
echo =====================================================================
echo.
echo Launching formal PowerPoint presentation (.pptx)...
echo.

if exist "Wind_Turbine_Pitch_Control_System_Internship_Presentation.pptx" (
    start "" "Wind_Turbine_Pitch_Control_System_Internship_Presentation.pptx"
    echo Presentation file opened successfully in PowerPoint!
) else (
    echo Error: Presentation file not found. Generating it now...
    node Internship_Presentation/generate_pptx.js
    start "" "Wind_Turbine_Pitch_Control_System_Internship_Presentation.pptx"
)

echo.
echo Presentation File Location:
echo  "%~dp0Wind_Turbine_Pitch_Control_System_Internship_Presentation.pptx"
echo.
echo Presentation Notes & Script Guide:
echo  "%~dp0INTERNSHIP_PRESENTATION_SCRIPT.md"
echo.
pause
