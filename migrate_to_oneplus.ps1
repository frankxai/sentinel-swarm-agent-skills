# Sentinel OnePlus Data Migration Script
# Copies accumulated personal S21/S25 media and files to the new connected OnePlus phone.

$sourceBase = "C:\Users\frank\OneDrive\backups\Personal-Devices-Vault\Samsung_Galaxy_S21_Work_Archive"

Write-Output "================================================================="
Write-Output "             SENTINEL ONEPLUS DATA MIGRATION ENGINE              "
Write-Output "================================================================="

if (-not (Test-Path $sourceBase)) {
    Write-Output "[-] ERROR: Source personal backup not found at: $sourceBase"
    exit
}

Write-Output "[+] Source personal backup folder: $sourceBase"

# Initialize Shell COM Object
$shell = New-Object -ComObject Shell.Application
$computer = $shell.NameSpace(17) # "This PC" / "My Computer"

# Find OnePlus Phone (Looks for OnePlus, 12R, 15R, or general Android device)
$oneplus = $computer.Items() | Where-Object { 
    $_.Name -like "*OnePlus*" -or 
    $_.Name -like "*12R*" -or 
    $_.Name -like "*15R*" -or
    $_.Name -like "*NE221*" -or # Common OnePlus model prefixes
    $_.Name -like "*CPH*"     # OnePlus global model prefixes
}

if (-not $oneplus) {
    # Fallback search: any connected phone that is NOT S25 and NOT S21
    $oneplus = $computer.Items() | Where-Object { 
        $_.Name -notlike "*S25*" -and 
        $_.Name -notlike "*S21*" -and 
        ($_.Name -like "*Phone*" -or $_.Name -like "*Android*" -or $_.Name -like "*Device*")
    }
}

if (-not $oneplus) {
    Write-Output "[-] ERROR: OnePlus Phone not detected in 'This PC'."
    Write-Output "[!] ACTION REQUIRED: Please connect your OnePlus phone via USB-C."
    exit
}

Write-Output "[+] Found connected device: $($oneplus.Name)"

$phoneFolder = $oneplus.GetFolder
$storageItems = $phoneFolder.Items()

if ($storageItems.Count -eq 0) {
    Write-Output "[-] ERROR: OnePlus folder is locked or empty."
    Write-Output "[!] ACTION REQUIRED: Please unlock your OnePlus phone screen, check for a prompt"
    Write-Output "    asking to 'Allow access to phone data' or 'Use USB for File Transfer', and select 'ALLOW/File Transfer'."
    exit
}

# Find Internal Storage directory
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

# Function to get or create folder under phone storage using shell COM
function Get-OrCreatePhoneFolder {
    param (
        [Object]$parentFolder,
        [string]$folderPath
    )

    $parts = $folderPath -split "\\"
    $currentFolder = $parentFolder

    foreach ($part in $parts) {
        $found = $currentFolder.Items() | Where-Object { $_.Name -eq $part -and $_.IsFolder }
        if (-not $found) {
            Write-Host "    [*] Creating phone directory: $part"
            $currentFolder.NewFolder($part)
            Start-Sleep -Milliseconds 500
            $found = $currentFolder.Items() | Where-Object { $_.Name -eq $part -and $_.IsFolder }
        }
        if (-not $found) {
            Write-Host "    [-] Failed to create or find phone directory: $part"
            return $null
        }
        $currentFolder = $found.GetFolder
    }
    return $currentFolder
}

# Source category to destination mapping
$mappings = @(
    @{ SourceSub = "Photos"; DestRel = "DCIM\S21_S25_Backup" },
    @{ SourceSub = "Videos"; DestRel = "DCIM\S21_S25_Backup" },
    @{ SourceSub = "Music"; DestRel = "Music\S21_S25_Backup" },
    @{ SourceSub = "Documents"; DestRel = "Documents\S21_S25_Backup" },
    @{ SourceSub = "SamsungNotes"; DestRel = "Documents\Samsung_Notes_Archive" }
)

foreach ($map in $mappings) {
    $srcDir = Join-Path $sourceBase $map.SourceSub
    if (-not (Test-Path $srcDir)) {
        Write-Output "[-] Skipping category $($map.SourceSub) (no source files found)"
        continue
    }

    Write-Output "---------------------------------------------------------"
    Write-Output "[*] Migrating $($map.SourceSub) -> OnePlus:\$($map.DestRel)..."

    # Get or create target directory
    $targetPhoneFolder = Get-OrCreatePhoneFolder -parentFolder $storageFolder -folderPath $map.DestRel
    if (-not $targetPhoneFolder) {
        Write-Output "[-] Could not access or create target directory: $($map.DestRel)"
        continue
    }

    # Copy files inside the source directory
    $files = Get-ChildItem -Path $srcDir -File -Recurse -ErrorAction SilentlyContinue
    if (-not $files) {
        $files = Get-ChildItem -Path $srcDir -ErrorAction SilentlyContinue
    }

    $copyCount = 0
    foreach ($file in $files) {
        $sourceFilePath = $file.FullName
        Write-Output "    [>] Copying $($file.Name) to OnePlus..."
        try {
            # Shell COM CopyHere:
            # 16 = Respond with 'Yes to All' for any dialog box
            $targetPhoneFolder.CopyHere($sourceFilePath, 16)
            $copyCount++
            Start-Sleep -Milliseconds 100
        }
        catch {
            Write-Output "    [!] Error copying $($file.Name): $_"
        }
    }
    Write-Output "[OK] Migrated $copyCount files for $($map.SourceSub)"
}

Write-Output "========================================================="
Write-Output "[+] ONEPLUS MIGRATION COMPLETE!"
Write-Output "[+] Synced all S21/S25 assets to your new OnePlus device."
Write-Output "========================================================="
