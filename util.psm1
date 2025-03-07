﻿Push-Location $PSScriptRoot

# Import all single function files
Get-ChildItem -filter '*-*' |
Where-Object Name -NotLike '*.Tests.ps1' |
ForEach-Object {
    . $_.FullName
}

# Import function collections
. .\Shortcut.ps1

Pop-Location
