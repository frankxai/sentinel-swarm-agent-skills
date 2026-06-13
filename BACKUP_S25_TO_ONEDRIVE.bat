@echo off
title Sentinel S25 to OneDrive Backup
echo =================================================================
echo             SENTINEL S25 TO ONEDRIVE BACKUP ENGINE
echo =================================================================
echo.
echo This script will scan your connected Samsung Galaxy S25 phone
echo and backup all your new S25 Camera Photos, S25 Videos, and
echo AI Videos directly to your personal OneDrive Devices Vault.
echo.
echo IMPORTANT ACTION REQUIRED:
echo 1. Ensure your S25 screen is UNLOCKED.
echo 2. Check for a popup on your S25 phone screen asking to:
echo    "Allow access to phone data?" and tap ALLOW.
echo.
echo Press any key when the phone is unlocked and ready to backup...
pause > nul
echo.
echo Initiating backup...
powershell -ExecutionPolicy Bypass -File "%USERPROFILE%\starlight\tools\backup_s25_to_onedrive.ps1"
echo.
echo =================================================================
echo Backup Process Finished!
echo =================================================================
echo.
pause
