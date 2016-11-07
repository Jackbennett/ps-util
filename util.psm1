Push-Location $PSScriptRoot

# Import all single function files
Get-ChildItem -Filter '*-*' |
    ForEach {
        . $_.FullName
    }

# Import function collections
. .\SystemInformation.ps1
. .\Shortcut.ps1

Pop-Location
