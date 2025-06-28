# == Prerequisites
#   1. Download and install butler <https://itchio.itch.io/butler>
#   2. Login with `butler login`
#   3. Place this script in _PROJECT_ROOT_/Misc/upload_itchio.ps1
#   4. Set GODOT_CONSOLE_PATH with `setx GODOT_CONSOLE_PATH "D:\OneDrive\Projets\Programmes\Godot\Godot_console.exe"`
#   5. Open Godot and export one time with the "Web" preset
# == Run
#   - cd _YOUR_PROJECT_ROOT_PATH_
#   - powershell .\Misc\upload_itchio.ps1
# == If error
# In cas of permissions error, use :
#   - cd _YOUR_PROJECT_ROOT_PATH_
#   - Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
#   - powershell -ExecutionPolicy Bypass -File ".\Misc\upload_itchio.ps1"

# Computer Environment
$GODOT_CONSOLE_PATH = $env:GODOT_CONSOLE_PATH

# Project Constants
$BUILD_FILENAME = "severed-finger"
$ITCH_PROJECT = "severed-finger"
$ITCH_CHANNEL = "html5"
$ITCH_USER = "5kender"

# Get script directory (Misc folder)
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
# Get project root (parent of Misc)
$projectRoot = Split-Path -Parent $scriptPath

# Change to project root
Set-Location $projectRoot

# Get current date in required format
$date = (Get-Date -Format "yyyy.MM.dd_HH.mm.ss")
$buildPath = "Build/${BUILD_FILENAME}_${date}"

# Create build directory
New-Item -ItemType Directory -Force -Path $buildPath

# Export game
& $GODOT_CONSOLE_PATH --headless --path "." --export-release "Web" "$buildPath/index.html"

# Pack to zip
$zipPath = "$buildPath.zip"
Compress-Archive -Path "$buildPath\*" -DestinationPath $zipPath -Force

# Upload via butler (both channels)
butler push --userversion "${date}" $zipPath "${ITCH_USER}/${ITCH_PROJECT}:${ITCH_CHANNEL}"
