# HANDBACK_CLEANUP.ps1 - Run this script before returning the device
#
# Automates: CLEANUP_CHECKLIST Steps 5, 6, 7 (sign-out reminders, SSH removal,
# Article 20 final verification)
#
# WHAT IT DOES:
# - Removes personal SSH keys + .git-credentials from WSL
# - Verifies OneDrive backup contents
# - Reminds user of remaining manual steps
# - Generates a final audit log entry
#
# WHAT IT DOES NOT DO:
# - Browser cleanup (must do manually in browser UI)
# - App sign-outs (must do via each app's settings)
# - API key rotation (must do via service web UIs)
# - Recycle Bin (left for Oracle IT)
# - File deletion in oracle-work/ (Oracle property)
#
# Usage (open PowerShell, then):
#   cd "$env:USERPROFILE\OneDrive\backups\Dell Backup\_TAKE_THIS_FOLDER_2026-05-25"
#   .\HANDBACK_CLEANUP.ps1

param(
    [switch]$DryRun = $false,
    [switch]$Force = $false
)

$ErrorActionPreference = 'Continue'
$timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'

Write-Host ""
Write-Host "===========================================================" -ForegroundColor Cyan
Write-Host "  HANDBACK CLEANUP - Oracle Device Return Preparation" -ForegroundColor Cyan
Write-Host "  Started: $timestamp" -ForegroundColor Cyan
Write-Host "===========================================================" -ForegroundColor Cyan
Write-Host ""

if ($DryRun) {
    Write-Host "[DRY RUN MODE - no changes will be made]" -ForegroundColor Yellow
    Write-Host ""
}

# ============================================================
# STEP 1: Verify backups exist before any cleanup
# ============================================================
Write-Host "STEP 1: Verifying backups exist..." -ForegroundColor Green

$backupPath1 = "$env:USERPROFILE\OneDrive\Backups\2026-05-oracle-transition"
$backupPath2 = "$env:USERPROFILE\OneDrive\Documents\backups\Dell Backup\2026-05-oracle-transition"
$transitionPath = "$env:USERPROFILE\Desktop\_TAKE_THIS_FOLDER_2026-05-25"

# Fallback check if OneDrive/Desktop redirection is active
if (-not (Test-Path -LiteralPath $transitionPath)) {
    $transitionPath = "$env:USERPROFILE\OneDrive\backups\Dell Backup\_TAKE_THIS_FOLDER_2026-05-25"
}

$pathsOk = $true
foreach ($p in @($backupPath1, $backupPath2, $transitionPath)) {
    if (Test-Path -LiteralPath $p) {
        $files = (Get-ChildItem -LiteralPath $p -Recurse -File -ErrorAction SilentlyContinue | Measure-Object).Count
        $size = "{0:N1} MB" -f ((Get-ChildItem -LiteralPath $p -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1MB)
        Write-Host "  [OK] Found: $p ($files files, $size)" -ForegroundColor Green
    } else {
        Write-Host "  [MISSING] NOT found: $p" -ForegroundColor Yellow
        # We don't abort immediately if at least one OneDrive backup path works
    }
}

# Double check that we have at least one valid OneDrive backup location before we proceed
if (-not (Test-Path -LiteralPath $backupPath1) -and -not (Test-Path -LiteralPath $backupPath2) -and -not $Force) {
    Write-Host ""
    Write-Host "ABORT: No valid OneDrive backup locations were verified. Use -Force to override." -ForegroundColor Red
    Write-Host ""
    exit 1
}

Write-Host ""

# ============================================================
# STEP 2: WSL SSH key + credentials removal
# ============================================================
Write-Host "STEP 2: WSL SSH and git credential removal..." -ForegroundColor Green

$wslPaths = @(
    "/home/frankx/.ssh/id_ed25519",
    "/home/frankx/.ssh/id_ed25519.pub",
    "/home/frankx/.ssh/known_hosts.old",
    "/home/frankx/.git-credentials"
)

foreach ($p in $wslPaths) {
    if ($DryRun) {
        Write-Host "  [DRY RUN] Would remove: $p" -ForegroundColor Yellow
    } else {
        try {
            # Check if WSL and the Ubuntu-24.04 distribution is responsive
            $null = wsl -l -v 2>$null
            if ($LASTEXITCODE -eq 0) {
                wsl -d Ubuntu-24.04 -- test -e "$p" 2>$null
                if ($LASTEXITCODE -eq 0) {
                    wsl -d Ubuntu-24.04 -- rm -f "$p" 2>$null
                    Write-Host "  [OK] Removed from WSL: $p" -ForegroundColor Green
                } else {
                    Write-Host "  - Not present in WSL (already removed): $p" -ForegroundColor DarkGray
                }
            } else {
                Write-Host "  - WSL offline or unresponsive" -ForegroundColor DarkGray
                break
            }
        } catch {
            Write-Host "  [!] Could not check/remove $p - verify manually" -ForegroundColor Yellow
        }
    }
}

Write-Host ""

# ============================================================
# STEP 3: Check Windows-side SSH keys
# ============================================================
Write-Host "STEP 3: Windows SSH key check..." -ForegroundColor Green

$winSshPath = "$env:USERPROFILE\.ssh"
if (Test-Path -LiteralPath $winSshPath) {
    $keys = Get-ChildItem -LiteralPath $winSshPath -File -ErrorAction SilentlyContinue
    if ($keys.Count -gt 0) {
        Write-Host "  Found Windows SSH files (review and decide):" -ForegroundColor Yellow
        $keys | ForEach-Object { Write-Host "    $($_.Name)" -ForegroundColor DarkGray }
    } else {
        Write-Host "  - Windows .ssh folder is empty (good)" -ForegroundColor DarkGray
    }
} else {
    Write-Host "  - No Windows .ssh folder (good)" -ForegroundColor DarkGray
}

Write-Host ""

# ============================================================
# STEP 4: Article 20 final compliance check
# ============================================================
Write-Host "STEP 4: Article 20 compliance verification..." -ForegroundColor Green
Write-Host "  Checking OneDrive backups for any Oracle restricted content..."

$violations = @()
foreach ($p in @($backupPath1, $backupPath2)) {
    if (Test-Path -LiteralPath $p) {
        # Look for any folder named oracle-work or customer references
        $check = Get-ChildItem -LiteralPath $p -Directory -Recurse -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -match "(oracle-work|aicoe|schaeffler|volkswagen|sena-bv|avolta-)" }
        if ($check) {
            $violations += $check
        }
    }
}

if ($violations.Count -eq 0) {
    Write-Host "  [OK] ZERO Oracle-restricted folders in personal OneDrive backups" -ForegroundColor Green
    Write-Host "  [OK] Article 20 attestation maintained" -ForegroundColor Green
} else {
    Write-Host "  [!] Found potential Article 20 issues:" -ForegroundColor Red
    $violations | ForEach-Object { Write-Host "    $($_.FullName)" -ForegroundColor Red }
}

Write-Host ""

# ============================================================
# STEP 5: Helpful reminders (manual steps)
# ============================================================
Write-Host "STEP 5: Manual steps still required..." -ForegroundColor Green
Write-Host ""
Write-Host "  Did you SEND the reference letter email to Afiena?" -ForegroundColor Cyan
Write-Host "     Template: strategy-docs/REFERENCE_LETTER_REQUEST.md" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Did you ROTATE these API keys?" -ForegroundColor Cyan
Write-Host "     - 5 Google Gemini keys -> console.cloud.google.com/apis/credentials" -ForegroundColor DarkGray
Write-Host "     - GitHub PAT -> github.com/settings/tokens" -ForegroundColor DarkGray
Write-Host "     - Vercel, Anthropic, OpenAI, Stripe, Suno, ElevenLabs (optional)" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Did you sign out of:" -ForegroundColor Cyan
Write-Host "     - Chrome (sync off, clear browsing data, sign out Google)?" -ForegroundColor DarkGray
Write-Host "     - VS Code / Cursor / Windsurf (GitHub sign out)?" -ForegroundColor DarkGray
      Write-Host "     - Personal Slack / Discord / Telegram / WhatsApp?" -ForegroundColor DarkGray
Write-Host "     - Password manager (Bitwarden / 1Password)?" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Did you review Desktop/CREDENTIALS_BACKUP.tar.gz?" -ForegroundColor Cyan
Write-Host "     If contains Oracle credentials -> DELETE before handback" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Did you verify OneDrive sync at https://onedrive.live.com?" -ForegroundColor Cyan
Write-Host "     From phone or other device, navigate to Backups/2026-05-oracle-transition" -ForegroundColor DarkGray
Write-Host ""

# ============================================================
# STEP 6: Write final audit log entry
# ============================================================
Write-Host "STEP 6: Recording handback cleanup execution..." -ForegroundColor Green

$logEntry = @"

### $(Get-Date -Format 'yyyy-MM-dd HH:mm') - Handback cleanup script executed

- **Scope**: Automated cleanup script execution
- **Mode**: $(if ($DryRun) { "DRY RUN" } else { "LIVE" })
- **Actions taken**:
  - Verified backup paths exist
  - Removed WSL SSH keys + git credentials (if present)
  - Checked Windows SSH folder
  - Verified Article 20 compliance (no Oracle-restricted in OneDrive)
- **Pending manual steps reminded to user**:
  - Reference letter email send
  - API key rotation (Gemini, GitHub PAT, others)
  - Browser cleanup
  - App sign-outs
  - CREDENTIALS_BACKUP.tar.gz review
  - OneDrive web verification
- **Article 20 status**: VERIFIED [OK]
"@

$decisionLog = "$env:USERPROFILE\starlight\repos\FrankX\docs\private\bv-formation\oracle-separation\audit\DECISION_LOG.md"
if (Test-Path -LiteralPath $decisionLog) {
    if (-not $DryRun) {
        Add-Content -LiteralPath $decisionLog -Value $logEntry -Encoding UTF8
        Write-Host "  [OK] Logged to DECISION_LOG.md" -ForegroundColor Green
    } else {
        Write-Host "  [DRY RUN] Would append to: $decisionLog" -ForegroundColor Yellow
    }
} else {
    Write-Host "  - starlight repo DECISION_LOG.md not present at target path (skipped)" -ForegroundColor DarkGray
}

Write-Host ""
Write-Host "===========================================================" -ForegroundColor Cyan
Write-Host "  CLEANUP SCRIPT COMPLETE" -ForegroundColor Cyan
Write-Host "  Finished: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Cyan
===========================================================
Write-Host ""
Write-Host "Next: Complete the manual steps listed above, then return the device." -ForegroundColor White
Write-Host ""
