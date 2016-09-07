$modules = Import-LocalizedData -FileName 'util.psd1'

$modules.FunctionsToExport |
    ForEach {
        $name = $psItem
        $files.Where( {$psitem -like "*$name*"} )
    } |
    sort -Unique |
    Foreach {
        . $_.FullName
    }
