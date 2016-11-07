Push-Location $PSScriptRoot

$modules = Import-LocalizedData -FileName 'util.psd1'

$files = Get-ChildItem
$filtered = $modules.FunctionsToExport |
    ForEach {
        $name = $psItem
        $files.Where( {$psitem.name -like "*$name*"} )
    } |
    ForEach {
        . $_.FullName
    }

. .\SystemInformation.ps1

Pop-Location
