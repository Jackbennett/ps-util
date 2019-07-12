<#
.SYNOPSIS
    Remove piped in object with a progress bar
.DESCRIPTION
    Showing a progress par with the current item and path, recusively delete the piped objects.
.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    General notes
#>
function Remove-MultiDirectory{
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.IO.DirectoryInfo[]]
        [Alias('PSPath')]
        $Path
    )
    Begin{
    }
    Process{
        $index = 0
        foreach($f in $Path){
            $index += 1
            $parent = split-path -Parent $f.fullname
            $progress = @{
                ID = 1
                Activity = 'Removing items with Recursive Force'
                Status = "Removing under $parent"
                CurrentOperation = "Target: $($f.name)"
            }
            if($PSCmdlet.ShouldProcess($f.fullname, 'Remove with Recursive Force')){
                Write-Progress @progress
                Remove-Item $f.fullname -Recurse -Force
            }
        }
    }
}
