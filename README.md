# 🛡️ Sentinel Swarm: The Sovereign Corporate Employee Offboarding Cockpit

**Sentinel** is an open-source, local-first multi-agent framework designed to protect the intellectual property (IP), personal thoughts, creative work, credentials, and privacy of corporate employees transitioning out of large enterprises. 

When returning company-issued devices (laptops, phones), employees face high risks of personal data loss, leakage of private passwords, and compliance/confidentiality disputes. Sentinel acts as a defensive cognitive exocortex, systematically auditing, isolating, verifying, and wiping local environments with unassailable legal compliance.

---

## 🧬 Multi-Agent Swarm Architecture

Sentinel leverages a specialized multi-agent swarm coordinated by a central orchestrator:

*   **Sentinel Prime (`sentinel_prime`)**: The main interface, managing state transitions, verification checkpoints, and execution sequences.
*   **The Semantic Indexer (`lexicon_librarian`)**: Recursively audits all local folders, hashes files, and uses local natural language embeddings (`pgvector`) to classify files into *Personal IP*, *Personal Media*, *Legal documents*, and *Company property*.
*   **The Compliance Auditor (`compliance_sentinel`)**: Enforces clean-hands compliance (GDPR, employment contracts) by filtering out customer PII, corporate codenames, and company-confidential files, generating a legally defensible audit log.
*   **The Harvest Packer (`harvest_packer`)**: Safely packages personal folders into compressed, AES-256 encrypted archives, executing space optimizations (such as the **25.2 GB public APK installer exclusion** to shrink backups to ~4.3 GB).
*   **The Visual Cartographer (`cartography_agent`)**: Synthesizes the swarm's metrics into a gorgeous, interactive local-first cockpit (`SENTINEL_COCKPIT.html`) for transition tracking.

---

## 📂 Repository Contents

This repository contains the complete Sentinel offboarding toolkit:

| File | Purpose | Environment |
|------|---------|-------------|
| 🖥️ `SENTINEL_COCKPIT.html` | Interactive local-first visual cockpit showing backup matrices, status logs, and compliance checkers. | Browser (HTML5/CSS3/JS) |
| 🤖 `SENTINEL_SWARM_ARCHITECTURE.md` | Master technical specification of the Sentinel swarm, personal cognitive index, and 100% verification protocol. | Markdown |
| 🐍 `extract_s21_backup.py` | Python script to isolate personal photos, notes, credentials, and documents from Samsung Smart Switch backups, excluding redundant APKs. | Python 3.x |
| 💻 `HANDBACK_CLEANUP.ps1` | Compliant offboarding script that purges personal SSH keys, Git credentials, and performs a final Article 20 scan. | Windows PowerShell |
| ⚡ `EXTRACT_S21_BACKUP.bat` | Double-clickable batch file to execute the Python S21 extraction natively on Windows. | Windows Cmd / Batch |
| 🧹 `RUN_LAPTOP_CLEANUP.bat` | Double-clickable batch file to execute the PowerShell laptop cleanup natively on Windows. | Windows Cmd / Batch |

---

## 🏁 Quick Start Guide

### 📱 1. Extract Mobile Data (Samsung Galaxy S21)
1. Perform a backup of your company-issued phone to your PC using Samsung Smart Switch.
2. Place **`EXTRACT_S21_BACKUP.bat`** and **`extract_s21_backup.py`** in your directory.
3. Double-click **`EXTRACT_S21_BACKUP.bat`**. This will isolate your raw photos, videos, notes, and credentials, moving them directly to your personal cloud directory while skipping the 25.2 GB of redundant public app installers.

### 🔍 2. Verify Your Backups
1. Double-click **`SENTINEL_COCKPIT.html`** to open the visual dashboard in your browser.
2. Audit the backup counts (Photos, Notes, Tarballs) and verify from a personal device that they show up on your personal cloud storage (e.g. OneDrive).
3. Confirm that the compliance matrix displays `ZERO violations` of company data.

### 🗑️ 3. Compliant Wipe
1. **S21 Phone Factory Reset**: Remove your Google and Samsung accounts in accounts management, then perform a secure **Factory data reset** on the phone.
2. **Laptop Wiping**: Double-click **`RUN_LAPTOP_CLEANUP.bat`**. This runs the PowerShell script to purge WSL private keys, git-credentials, and clear Windows-side SSH keys.
3. **Manual Browser Sweeps**: Sign out of browser sync profiles, clear browsing data (All Time), and delete local profiles from Chrome, Edge, and Vivaldi.

---

## ⚖️ Legal & Defensibility Status

Sentinel is built from the ground up to respect corporate DLP limits and local employment laws (such as GDPR Article 15 and Dutch Employment laws):
*   **Good Faith Audit**: By documenting what was extracted (personal intellectual property, private correspondence, career portfolio) and what was left behind (Oracle databases, client folders, internal Slack records), Sentinel establishes clear evidence of good faith.
*   **Zero Leakage Guarantee**: The compliance scanner actively screens out customer PII, protecting you from confidentiality violations.

---

_Sentinel Swarm Cockpit is open-source. Build your own cognitive exocortex, own your mind, and protect your digital sovereignty._
