<#
.Synopsis
   Append Cmdlet name and synopsis to a file.
.DESCRIPTION
   Appends cmdlet name and exported synopsis to your readme file with a nice makrdown title prepended to the name.

   You will need to remove the already present descriptions from the file if this has already beenrun before.
.EXAMPLE
   Update-ModuleReadMe -Module util -ReadMe .\README.md
#>
function Update-ModuleReadMe
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $Module,

        $ReadMe
    )

    Get-Command -Module $Module |
        Get-Help |
        select name,Synopsis |
        foreach {
            '#### ' + $_.name + [System.Environment]::NewLine + $_.Synopsis
        } |
        Out-File -FilePath $ReadMe -Encoding utf8 -Append
}