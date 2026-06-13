@echo off
title Sentinel OnePlus Data Migrator
echo =================================================================
echo             SENTINEL ONEPLUS DATA MIGRATION ENGINE
echo =================================================================
echo.
echo This script will migrate your accumulated S21/S25 personal data
echo (Photos, Videos, Music, Documents, Notes) directly onto your newly
echo connected OnePlus primary phone.
echo.
echo IMPORTANT ACTION REQUIRED:
echo 1. Ensure your OnePlus screen is UNLOCKED.
echo 2. Check for a popup on your OnePlus screen asking to:
echo    "Use USB to Transfer Files" or "File Transfer" (MTP) and tap ALLOW.
echo.
echo Press any key when the OnePlus is unlocked and ready to migrate...
pause > nul
echo.
echo Initiating migration...
powershell -ExecutionPolicy Bypass -File "%USERPROFILE%\starlight\tools\migrate_to_oneplus.ps1"
echo.
echo =================================================================
echo OnePlus Migration Process Finished!
echo =================================================================
echo.
pause
