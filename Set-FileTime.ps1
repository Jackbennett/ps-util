Function Set-FileTime {
    [CmdletBinding()]
    <# 
        .SYNOPSIS  
            Change the file date/times
        .Description
            Use this to update file times, for example from cameras that do not have a date set.
        .EXAMPLE 
            ls | Set-FileTime
    #>
    Param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [System.IO.FileInfo[]]$InputObject,
        [Parameter(Position=0)]
        [datetime]$date = (Get-Date)
    )
    Process{
        ForEach($file in $InputObject) {
            $file.CreationTime = $date
            $file.LastWriteTime = $date
            $file.LastAccessTime = $date
        }
    }
}
