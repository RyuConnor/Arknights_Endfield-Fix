# --- CONFIGURATION ---
#Note run Set-ExecutionPolicy RemoteSigned -Scope CurrentUser to allow this script to work
$scriptDir = $PSScriptRoot  # Automatically detects the folder the script is in
$launcherPath = Join-Path $scriptDir "launcher.exe"
$aceGuid = "S43F9F03-T312-D930-N88-B74BA0B3"

Set-Location $scriptDir

# --- ENVIRONMENT OVERRIDES ---
$env:QT_QUICK_BACKEND = "d3d11"
$env:__COMPAT_LAYER = "RunAsInvoker"

# --- PRE-FLIGHT CLEANUP ---
Write-Host "--- ACE Trace Janitor: Initializing ---" -ForegroundColor White
if ((logman query -ets) -match $aceGuid) {
    logman stop "$aceGuid" -ets | Out-Null
    Write-Host "[+] Initial kernel state cleared." -ForegroundColor Green
}

# --- INITIAL LAUNCH ---
Write-Host "Starting Launcher..." -ForegroundColor Green
Start-Process -FilePath $launcherPath
Start-Sleep -Seconds 5 

# --- MAIN MONITORING LOOP ---
Write-Host "Janitor Status: MONITORING... (Close Launcher to exit)" -ForegroundColor Cyan

try {
    while ($true) {
        $launcher = Get-Process "games", "GRYPHLINK" -ErrorAction SilentlyContinue | Select-Object -First 1
        $game = Get-Process "Endfield" -ErrorAction SilentlyContinue | Select-Object -First 1

        # --- CASE 1: GAME IS RUNNING ---
        if ($game) {
            Write-Host "[+] Game Detected. Monitoring session..." -ForegroundColor White
            
            # BLOCKING WAIT: Script pauses here until the game is closed
            $game.WaitForExit()
            
            # --- IMMEDIATE SESSION CLEANUP ---
            Write-Host "[!] Game Exit Detected. Flushing ACE Trace..." -ForegroundColor Yellow
            Start-Sleep -Seconds 3 # 3s Cooldown to avoid "Event Log 2"
            
            if ((logman query -ets) -match $aceGuid) {
                logman stop "$aceGuid" -ets | Out-Null
                Write-Host "[+] Trace Cleared. Ready for next session." -ForegroundColor Green
            }

            continue # Re-evaluate launcher state
        }

        # --- CASE 2: LAUNCHER CLOSED ---
        if ($null -eq $launcher) {
            if ((logman query -ets) -match $aceGuid) {
                logman stop "$aceGuid" -ets | Out-Null
            }
            break 
        }

        # --- CASE 3: IDLE ---
        $launcher.WaitForExit(5000) | Out-Null
    }
}
finally {
    Write-Host "`nJanitor signing off." -ForegroundColor White
    Start-Sleep -Seconds 2
}