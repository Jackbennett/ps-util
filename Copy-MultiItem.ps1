<#
.Synopsis
   Copy 1 or more items to multiple desitnations
.DESCRIPTION
   Wraps `copy-item` to provide multiple destinations. Great for putting one set of files on many users home drives.
#>
function Copy-MultiItem
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    [OutputType([System.IO.FileInfo])]
    Param
    (
        # What to copy from
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string[]]
        $Source

        , # Where to copy to
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [Alias('Target')]
        [string[]]
        $Path

        , # Output the item copied
        [switch]
        $PassThru

        , # Output the item copied
        [switch]
        $Recurse

        , # Overwrite items that exist
        [switch]
        $Force
    )
    Process{
        foreach ($location in $Path){
            Write-Verbose "Copy $Source to $Location"
            if ($PSCmdlet.ShouldProcess($Location, "Copy $Source")) {
                Copy-Item -Path $Source -Destination $location -Recurse:$Recurse -PassThru:$PassThru -Force:$Force
            }
        }
    }
}
