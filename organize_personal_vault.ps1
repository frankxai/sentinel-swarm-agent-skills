# Organize Personal Devices Vault Script
# Creates a unified, beautiful folder structure in personal OneDrive for all devices.

$vaultBase = "C:\Users\frank\OneDrive\backups\Personal-Devices-Vault"
$s21Source = "C:\Users\frank\OneDrive\backups\2026-05-oracle-transition\S21_Extracted_Personal"

Write-Output "================================================================="
Write-Output "             SENTINEL PERSONAL DEVICES VAULT CREATOR              "
Write-Output "================================================================="

# Create folder structure
$folders = @(
    "Samsung_Galaxy_S21_Work_Archive",
    "Samsung_Galaxy_S25_Personal",
    "Samsung_Galaxy_S9_Legacy",
    "Huawei_P30_Legacy",
    "OnePlus_Active_Sync",
    "Lenovo_Laptop_Cockpit"
)

foreach ($folder in $folders) {
    $path = Join-Path $vaultBase $folder
    if (-not (Test-Path $path)) {
        Write-Output "[*] Creating vault directory: $folder"
        New-Item -Path $path -ItemType Directory -Force | Out-Null
    } else {
        Write-Output "[OK] Vault directory exists: $folder"
    }
}

# Sync S21 Extracted data into the archive vault
$s21Dest = Join-Path $vaultBase "Samsung_Galaxy_S21_Work_Archive"
if (Test-Path $s21Source) {
    Write-Output "[*] Syncing S21 Extracted Personal data to Vault Archive..."
    # Copy files recursively
    Copy-Item -Path "$s21Source\*" -Destination $s21Dest -Recurse -Force -ErrorAction SilentlyContinue
    Write-Output "[OK] S21 personal data successfully synced to the central vault."
} else {
    Write-Output "[-] Note: S21 Extracted source not found at default path, skipping sync."
}

# Create README inside the Vault to instruct future agents
$readmePath = Join-Path $vaultBase "README.md"
$readmeContent = @"
# 🌌 Sovereign Personal Devices Vault

Welcome to the central storage and synchronization vault for all of Frank Riemer's personal devices. This directory is synced with personal OneDrive for absolute data sovereignty.

## 📱 Device Mapping & Sync Status

1. **Samsung Galaxy S21 (Work Phone - Wiped/Returned)**:
   * **Folder**: `Samsung_Galaxy_S21_Work_Archive/`
   * **Status**: ✅ BACKED UP & ARCHIVED. Extracted personal assets (1,902 files, 2.57 GB) including Photos, Videos, Music, Documents, and legacy Notes/Passwords.
   
2. **Samsung Galaxy S25 (Personal Phone - Active/Migrated)**:
   * **Folder**: `Samsung_Galaxy_S25_Personal/`
   * **Status**: ✅ IN SYNC. Migrated from S21 and fully backed up.
   
3. **OnePlus (Active Primary Personal Phone)**:
   * **Folder**: `OnePlus_Active_Sync/`
   * **Status**: 🔄 MIGRATION READY. Use `MIGRATE_TO_ONEPLUS.bat` on the Desktop to push S21/S25 data.
   
4. **Huawei P30 (Legacy Personal Phone)**:
   * **Folder**: `Huawei_P30_Legacy/`
   * **Status**: 🗄️ LEGACY HOLDER. (Place any manual Huawei local backup files here).
   
5. **Samsung Galaxy S9 (Legacy Personal Phone - Kept)**:
   * **Folder**: `Samsung_Galaxy_S9_Legacy/`
   * **Status**: 🗄️ LEGACY HOLDER. (Frank's legacy personal phone archives).
   
6. **Lenovo Laptop (Cockpit - Active)**:
   * **Folder**: `Lenovo_Laptop_Cockpit/`
   * **Status**: 🖥️ ACTIVE COMMAND CENTER. Syncing all configuration repos, Git credentials, and exocortex playbooks.

## 🛠️ Unified Migration & Control Tools
All terminal scripts, automation tools, and coordinate playbooks are tracked in the private GitHub repository:
🔗 **https://github.com/frankxai/sentinel-swarm-agent-skills**
"@

Set-Content -Path $readmePath -Value $readmeContent -Force
Write-Output "[OK] Created Vault README.md"
Write-Output "================================================================="
Write-Output "[+] CENTRAL DEVICES VAULT READY!"
Write-Output "================================================================="
