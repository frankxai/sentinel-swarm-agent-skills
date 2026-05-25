@echo off
title Sentinel S21 Personal Data Extractor
echo =================================================================
echo        SENTINEL S21 BACKUP EXTRACTION & VERIFICATION
echo =================================================================
echo.
echo This script will isolate, copy, and verify your S21 personal data 
echo (Photos, Videos, Notes, Credentials, Docs) from your Smart Switch backup.
echo It will exclude the redundant 25.2 GB of public app installers.
echo.
echo Running Python extraction script...
echo.
python "%USERPROFILE%\starlight\tools\extract_s21_backup.py"
echo.
echo =================================================================
echo Extraction Process Complete!
echo =================================================================
echo.
pause
