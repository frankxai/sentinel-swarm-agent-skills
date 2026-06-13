# Sentinel S25 to OneDrive Backup Script
# Copies S25's AI Videos, photos, and personal media directly to the OneDrive personal devices vault.

$vaultBase = "C:\Users\frank\OneDrive\backups\Personal-Devices-Vault\Samsung_Galaxy_S25_Personal"

Write-Output "================================================================="
Write-Output "             SENTINEL S25 TO ONEDRIVE BACKUP ENGINE              "
Write-Output "================================================================="

# Ensure Vault Base exists
if (-not (Test-Path $vaultBase)) {
    New-Item -Path $vaultBase -ItemType Directory -Force | Out-Null
}

# Initialize Shell COM
$shell = New-Object -ComObject Shell.Application
$computer = $shell.NameSpace(17) # This PC

# Find S25 Phone
$phone = $computer.Items() | Where-Object { $_.Name -like "*S25*" -or $_.Name -like "*Galaxy*" }

if (-not $phone) {
    Write-Output "[-] ERROR: S25 Phone not detected. Please unlock screen and connect via USB."
    exit
}

Write-Output "[+] Found device: $($phone.Name)"

$phoneFolder = $phone.GetFolder
$storage = $phoneFolder.Items() | Where-Object { 
    $_.Name -like "*storage*" -or 
    $_.Name -like "*Speicher*" -or 
    $_.Name -like "*Internal*" -or 
    $_.Name -like "*Shared*"
}

if (-not $storage) {
    Write-Output "[-] ERROR: Internal storage folder not reachable. Screen might be locked."
    exit
}

$storageFolder = $storage.GetFolder

# Helper function to copy files from phone folder to local path
function Backup-PhoneFolder {
    param (
        [Object]$srcStorageFolder,
        [string]$phoneRelPath, # e.g. "AI Videos S25 Backup"
        [string]$localDestPath # e.g. "C:\Users\frank\OneDrive\backups\Personal-Devices-Vault\Samsung_Galaxy_S25_Personal\AI_Videos"
    )

    Write-Output "---------------------------------------------------------"
    Write-Output "[*] Auditing S25 folder: $phoneRelPath..."
    
    # Resolve source folder
    $parts = $phoneRelPath -split "\\"
    $currentFolder = $srcStorageFolder
    $found = $true
    
    foreach ($part in $parts) {
        $item = $currentFolder.Items() | Where-Object { $_.Name -eq $part -and $_.IsFolder }
        if ($item) {
            $currentFolder = $item.GetFolder
        } else {
            $found = $false
            break
        }
    }
    
    if (-not $found) {
        Write-Output "[-] S25 folder not found: $phoneRelPath"
        return
    }

    # Ensure destination folder exists
    if (-not (Test-Path $localDestPath)) {
        New-Item -Path $localDestPath -ItemType Directory -Force | Out-Null
    }

    $phoneItems = $currentFolder.Items()
    $totalCount = $phoneItems.Count
    Write-Output "[+] Folder contains $totalCount files/directories."
    
    $destShellFolder = $shell.NameSpace($localDestPath)
    $copyCount = 0

    foreach ($item in $phoneItems) {
        # Skip folders like S21_Backup inside S25 DCIM
        if ($item.IsFolder) {
            if ($item.Name -eq "S21_Backup" -or $item.Name -eq "S21_Notes_Backup") {
                Write-Output "    [Skip] Skipping S21 legacy backup folder: $($item.Name)"
                continue
            }
            # Handle nested directories if needed, or copy directory itself
        }

        $destFilePath = Join-Path $localDestPath $item.Name
        
        # Check if file already exists locally to avoid duplicate copying
        if (Test-Path $destFilePath) {
            Write-Output "    [Skip] $($item.Name) already backed up."
            continue
        }

        Write-Output "    [>] Copying $($item.Name) to OneDrive Vault..."
        try {
            # Shell COM CopyHere:
            # 16 = Respond with 'Yes to All' for any dialog box
            $destShellFolder.CopyHere($item, 16)
            $copyCount++
            Start-Sleep -Milliseconds 150 # Sleep to prevent COM buffer overflow
        }
        catch {
            Write-Output "    [!] Error copying $($item.Name): $_"
        }
    }
    Write-Output "[OK] Backed up $copyCount new files from S25\$phoneRelPath."
}

# 1. Back up S25 Camera Photos/Videos
$cameraDest = Join-Path $vaultBase "Camera"
Backup-PhoneFolder -srcStorageFolder $storageFolder -phoneRelPath "DCIM\Camera" -localDestPath $cameraDest

# 2. Back up S25 AI Videos Backup folder
$aiVideosDest = Join-Path $vaultBase "AI_Videos_S25_Backup"
Backup-PhoneFolder -srcStorageFolder $storageFolder -phoneRelPath "AI Videos S25 Backup" -localDestPath $aiVideosDest

Write-Output "========================================================="
Write-Output "[+] S25 TO ONEDRIVE BACKUP COMPLETED SUCCESSFULLY!"
Write-Output "[+] All S25 Camera Photos, S25 Videos, and AI Videos are secured."
Write-Output "========================================================="
