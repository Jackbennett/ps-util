Push-Location $PSScriptRoot

# Import all single function files
Get-ChildItem -filter '*-*' |
    Where-Object Name -NotLike '*.Tests.ps1' |
    ForEach-Object {
        . $_.FullName
    }

# Import function collections
. .\SystemInformation.ps1
. .\Shortcut.ps1

Pop-Location
