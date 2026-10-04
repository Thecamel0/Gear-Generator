@echo off
title Launch Internship Technical Presentation
cd /d "%~dp0"

echo =====================================================================
echo  WIND TURBINE PITCH CONTROL SYSTEM - INTERNSHIP PRESENTATION
echo  Candidate: Ahmed Majdy Ahmed
echo =====================================================================
echo.
echo Launching formal engineering slide deck in your default browser...
echo.

start "" "Internship_Presentation\index.html"

echo Presentation launched successfully.
echo.
echo Presentation Controls:
echo  - Next Slide:      Right Arrow [->], Spacebar, PageDown
echo  - Previous Slide:  Left Arrow [<-], Backspace, PageUp
echo  - Presenter Notes: Press 'N'
echo  - Slide Overview:  Press 'O' or 'Escape'
echo  - Fullscreen:      Press 'F'
echo  - Export to PDF:   Click 'PDF' or press Ctrl+P
echo.
pause
