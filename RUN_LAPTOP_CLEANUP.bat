@echo off
title Sentinel Laptop Offboarding Cleanup
echo =================================================================
echo        SENTINEL COMPLIANT LAPTOP OFFBOARDING CLEANUP
echo =================================================================
echo.
echo This script will execute your HANDBACK_CLEANUP.ps1 to securely
echo wipe personal SSH keys, Git credentials, and verify compliance.
echo.
echo Running PowerShell script...
echo.
powershell.exe -ExecutionPolicy Bypass -File "%USERPROFILE%\OneDrive\backups\Dell Backup\_TAKE_THIS_FOLDER_2026-05-25\HANDBACK_CLEANUP.ps1"
echo.
echo =================================================================
echo Cleanup Process Complete!
echo =================================================================
echo.
pause
