<#
.Synopsis
   Copy 1 or more items to multiple desitnations
.DESCRIPTION
   Wraps `copy-item` to provide multiple destinations. Great for putting one set of files on many users home drives.
#>
function Copy-MultiItem
{
    [CmdletBinding()]
    [OutputType([System.IO.FileInfo])]
    Param
    (
        # What to copy from
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string[]]
        $Source,

        # Where to copy to
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [string[]]
        $Path,

        # Output the item copied
        [switch]
        $passThru
    )
    Process{
        foreach ($location in $Path){
            Write-Verbose "Copy $path to $Location"
            Copy-Item -Path $Source -Destination $location -passThru:$psssThru
        }
    }
}