<#
.Synopsis
   Create a new shortcut with specified properties
.DESCRIPTION
   Bypass Windows GUI property validation when setting shortcut attributes.
.EXAMPLE
   New-Shortcut '.\GIMP.lnk' -newname 'GIMP 2.8'
#>
function New-Shortcut
{
    [CmdletBinding()]
    Param
    (
        # Use an existing shortcut to update the target.
        [Parameter(Mandatory=$true,
                   Position=0)]
        [string]
        $Template

        , # New shortcut location
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string]
        $Path

        , # File path to target execution
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [string]
        $TargetPath = "C:\Program Files\"

        , # The "Comment" field under "Properties"
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [string]
        $Description = "New Shortcut Link"

    )

    Begin
    {
        $shell = New-Object -COM WScript.Shell
    }
    Process
    {
        $dest = Get-Item $Path
        $target = Get-Item $TargetPath
        Copy-Item $Template $dest.FullName  ## Get the lnk we want to use as a template
        $shortcut = $shell.CreateShortcut($dest.FullName)  ## Open the lnk

        $shortcut.TargetPath = $target.FullName
        $shortcut.Description = $Description
        $shortcut.Save()
    }
    End
    {
    }
}