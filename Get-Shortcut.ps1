<#
.Synopsis
   Get the shorcuts properties
.DESCRIPTION
   Copy the source shortcut into a variable to edit with the WScript shell methods

.EXAMPLE
   Gew-shortcut '.\GIMP.lnk'

#>
function Get-Shortcut
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    Param
    (
        # Use an existing shortcut to update the target.
        [Parameter(Mandatory=$true,
                   Position=0,
                   ValueFromPipelineByPropertyName=$true)]
        [string]
        $Path
    )

    Begin
    {
        $shell = New-Object -COM WScript.Shell
    }
    Process
    {
        $absolutePath = (Get-Item $Path).FullName
        
        $shell.CreateShortcut($absolutePath) 

        $shortcut
    }
    End
    {
        Remove-Variable shell
    }
}