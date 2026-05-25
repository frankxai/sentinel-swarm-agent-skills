# Sentinel S25 Data Migration Script
# Copies extracted personal S21 media and files to the new connected S25 phone.

$sourceBase = "C:\Users\frank\OneDrive\Backups\2026-05-oracle-transition\S21_Extracted_Personal"

Write-Output "================================================================="
Write-Output "               SENTINEL S25 DATA MIGRATION ENGINE                "
Write-Output "================================================================="

if (-not (Test-Path $sourceBase)) {
    Write-Output "[-] ERROR: Source personal backup not found at: $sourceBase"
    exit
}

Write-Output "[+] Source personal backup folder: $sourceBase"

# Initialize Shell COM Object
$shell = New-Object -ComObject Shell.Application
$computer = $shell.NameSpace(17) # "This PC" / "My Computer"

# Find S25 Phone
$phone = $computer.Items() | Where-Object { $_.Name -like "*S25*" -or $_.Name -like "*Galaxy*" }

if (-not $phone) {
    Write-Output "[-] ERROR: S25 Phone not detected in 'This PC'. Please connect it via USB-C."
    exit
}

Write-Output "[+] Found connected device: $($phone.Name)"

$phoneFolder = $phone.GetFolder
$storageItems = $phoneFolder.Items()

if ($storageItems.Count -eq 0) {
    Write-Output "[-] ERROR: S25 folder is locked or empty."
    Write-Output "[!] ACTION REQUIRED: Please unlock your S25 phone screen, check for a prompt"
    Write-Output "    asking to 'Allow access to phone data', and tap 'Allow'."
    Write-Output "    Also ensure USB settings are set to 'File Transfer' / 'MTP'."
    exit
}

# Find Internal Storage directory (handles both English and German/other languages)
$storage = $storageItems | Where-Object { 
    $_.Name -like "*storage*" -or 
    $_.Name -like "*Speicher*" -or 
    $_.Name -like "*Internal*" -or 
    $_.Name -like "*Shared*"
}

if (-not $storage) {
    # Fallback to the first available directory
    $storage = $storageItems | Select-Object -First 1
}

Write-Output "[+] Identified phone storage: $($storage.Name)"
$storageFolder = $storage.GetFolder
$storageItemsList = $storageFolder.Items()

# Function to get or create folder under phone storage using shell COM
function Get-OrCreatePhoneFolder {
    param (
        [Object]$parentFolder,
        [string]$folderPath # relative path e.g. "DCIM\S21_Backup" or "Documents"
    )

    $parts = $folderPath -split "\\"
    $currentFolder = $parentFolder

    foreach ($part in $parts) {
        $found = $currentFolder.Items() | Where-Object { $_.Name -eq $part -and $_.IsFolder }
        if (-not $found) {
            Write-Output "    [*] Creating phone directory: $part"
            # Note: Creating folders in MTP via COM is done using NewFolder on the folder object
            $currentFolder.NewFolder($part)
            Start-Sleep -Milliseconds 500
            # Retrieve again
            $found = $currentFolder.Items() | Where-Object { $_.Name -eq $part -and $_.IsFolder }
        }
        if (-not $found) {
            Write-Output "    [-] Failed to create or find phone directory: $part"
            return $null
        }
        $currentFolder = $found.GetFolder
    }
    return $currentFolder
}

# Source category to destination mapping
$mappings = @(
    @{ SourceSub = "Photos"; DestRel = "DCIM\S21_Backup" },
    @{ SourceSub = "Videos"; DestRel = "DCIM\S21_Backup" },
    @{ SourceSub = "Music"; DestRel = "Music\S21_Backup" },
    @{ SourceSub = "Documents"; DestRel = "Documents\S21_Backup" },
    @{ SourceSub = "SamsungNotes"; DestRel = "Documents\S21_Notes_Backup" }
)

foreach ($map in $mappings) {
    $srcDir = Join-Path $sourceBase $map.SourceSub
    if (-not (Test-Path $srcDir)) {
        Write-Output "[-] Skipping category $($map.SourceSub) (no source files found)"
        continue
    }

    Write-Output "---------------------------------------------------------"
    Write-Output "[*] Migrating $($map.SourceSub) -> Phone:\$($map.DestRel)..."

    # Get or create target directory
    $targetPhoneFolder = Get-OrCreatePhoneFolder -parentFolder $storageFolder -folderPath $map.DestRel
    if (-not $targetPhoneFolder) {
        Write-Output "[-] Could not access or create target directory: $($map.DestRel)"
        continue
    }

    # Copy files inside the source directory
    $files = Get-ChildItem -Path $srcDir -File -RecurRecurse -ErrorAction SilentlyContinue
    if (-not $files) {
        # Check if there are directories to copy instead
        $files = Get-ChildItem -Path $srcDir -ErrorAction SilentlyContinue
    }

    $copyCount = 0
    foreach ($file in $files) {
        $sourceFilePath = $file.FullName
        Write-Output "    [>] Copying $($file.Name) to phone..."
        try {
            # Shell COM CopyHere:
            # 16 = Respond with 'Yes to All' for any dialog box
            # 1024 = Do not show a progress dialog box if we want it silent, but showing it is good
            $targetPhoneFolder.CopyHere($sourceFilePath, 16)
            $copyCount++
            # Small sleep to prevent COM queue overflow
            Start-Sleep -Milliseconds 100
        }
        catch {
            Write-Output "    [!] Error copying $($file.Name): $_"
        }
    }
    Write-Output "[OK] Migrated $copyCount files for $($map.SourceSub)"
}

Write-Output "========================================================="
Write-Output "[+] MIGRATION COMPLETED SUCCESSFULLY!"
Write-Output "[+] Media, Music, and Documents have been synced to the S25."
Write-Output "[!] NOTE: For accounts, contacts, and Samsung Pass credentials,"
Write-Output "    please open the Samsung Smart Switch app on your PC,"
Write-Output "    select 'Restore', and select the backup folder: "
Write-Output "    $sourceBase"
Write-Output "========================================================="
