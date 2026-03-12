# Arknights_Endfield-Fix
This is a lightweight PowerShell wrapper designed to workaround the PlatformProcess.exe Access Violation crash and the Event ID 2 error in Arknights Endfield.
This was vibe coded with Gemini, assuming you consider shell scripts to be code.

## 🛠️ Issues Addressed

* **PlatformProcess.exe Access Violation:** Fixes the memory crash/Null Pointer exception by forcing the UI to use a stable rendering backend (`d3d11`). Despite setting d3d11, it falls back to software rendering. It solves the crash, but expect the store to render slowly as you swipe to obtain more waifus.
* **Event ID 2 (Kernel-EventTracing):** Resolves the "File already exists" error by proactively flushing "zombie" ACE anti-cheat traces that fail to close on game exit. To be clear this flushing is done after closing the game, not during. Messing with ACE while the game is active is obviously asking for trouble and this script does NOT do to that.

---

## 👨‍💻 Technical Summary (For Support/Developers)

* **Access Violation:** Forcing `$env:QT_QUICK_BACKEND = "d3d11"` bypasses a null pointer bug in `PlatformProcess.exe`. This prevents the memory violation/Access Violation (`0xc0000005`) when exiting the game.
* **Trace Persistence:** The ACE driver (or game engine) occasionally fails to terminate the Kernel Event Trace Session upon exit. This leaves a stale handle on the trace GUID (`S43F9F03-T312-D930-N88-B74BA0B3`).
* **Event ID 2:** When the game is re-launched, Windows denies the request to start a new trace session because the previous one is still active in the kernel. This script uses `logman stop` to cleanup the environment between sessions.

---

## 🚀 Installation & Usage

### 1. Enable PowerShell Scripts
By default, Windows blocks local scripts. To allow this tool to run:
1. Open **PowerShell** (Standard, no Admin needed for this step).
2. Run the following command:
   ```powershell
   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

### 2. Install the Script
Download Arknights_Endfield.ps1 from this repository.

Move the file into your game's installation folder (where Launcher.exe is located).

Example Path: D:\Games\GRYPHLINK

### 3. Create an Admin Desktop Shortcut
Because Endfield requires Admin rights, you will need Admin rights to fix the bugs. Another great example of why client anti-cheat is bad.

Right-click and choose New > Shortcut.

In the "Type the location of the item", copy and paste the following:

<pre><code>
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Start-Process powershell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"D:\Games\GRYPHLINK\EndfieldJanitor.ps1\"' -Verb RunAs"
</code></pre>

IMPORTANT: If your game is installed elsewhere, replace D:\Games\GRYPHLINK\Arknights_Endfield.ps1 with the actual path to your script.

Click Next, name the shortcut GRYPHLINK, and click Finish.

Verify: You can confirm this worked by right-clicking the shortcut and selecting Properties. The long command above will be listed in the Target box of the Shortcut tab.

Also on the Shortcut tab you can click "Change Icon..." then click "Browse..." go to where the GRYPHLINK\Launcher.exe is and select it.  Now your shortcut will use the same icon as the Launcher.

Double click your shortcut, elevate with UAC, and a powershell prompt should appear that will give you status updates.
