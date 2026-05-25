@echo off
title Sentinel S25 Data Migrator
echo =================================================================
echo             SENTINEL S25 DATA MIGRATION ENGINE
echo =================================================================
echo.
echo This script will migrate your extracted S21 personal data (Photos,
echo Videos, Music, Documents, and Notes) directly onto your newly
echo connected Samsung Galaxy S25 phone.
echo.
echo IMPORTANT ACTION REQUIRED:
echo 1. Ensure your S25 screen is UNLOCKED.
echo 2. Check for a popup on your S25 phone screen asking to:
echo    "Allow access to phone data?" and tap ALLOW.
echo 3. Ensure USB connection settings on the phone are set to:
echo    "File Transfer" or "Transferring files" (MTP).
echo.
echo Press any key when the phone is unlocked and ready to migrate...
pause > nul
echo.
echo Initiating migration...
powershell -ExecutionPolicy Bypass -File "%USERPROFILE%\starlight\tools\migrate_to_s25.ps1"
echo.
echo =================================================================
echo Migration Process Finished!
echo =================================================================
echo.
pause
