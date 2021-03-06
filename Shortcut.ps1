<#
.Synopsis
   Create a new shortcut with specified properties
.DESCRIPTION
   Bypass Windows GUI property validation when setting shortcut attributes.
.EXAMPLE
   New-Shortcut '.\GIMP.lnk' -Path '.\GIMP 2.8.lnk'
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
        # Always create a fully qualified path. COM will not edit the shortcut on a relative path.
        $dest = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)

        # Force the link extension creation incase it was unspecified in the Path
        if($dest -notLike '*.lnk'){
            $dest += '.lnk'
        }

        Copy-Item $Template $dest  ## Get the lnk we want to use as a template
        $shortcut = $shell.CreateShortcut($dest)  ## Open the lnk

        $shortcut.TargetPath = $TargetPath
        $shortcut.Description = $Description
        $shortcut.Save()
    }
    End
    {
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($shell) > $null
        Remove-Variable shell
    }
}

<#
.Synopsis
   Get the shorcuts properties
.DESCRIPTION
   Copy the source shortcut into a variable to edit with the WScript shell methods

.EXAMPLE
   Get-Shortcut .\Arduino.lnk

   FullName         : C:\users\Public\Desktop\Arduino.lnk
   Arguments        :
   Description      :
   Hotkey           :
   IconLocation     : ,0
   RelativePath     :
   TargetPath       : C:\Program Files (x86)\Arduino\arduino.exe
   WindowStyle      : 1
   WorkingDirectory : C:\Program Files (x86)\Arduino

.EXAMPLE
   ls -Filter *.lnk | get-shortcut | select targetpath

   TargetPath
   ----------
   C:\Program Files (x86)\Arduino\arduino.exe
   C:\Program Files (x86)\Google\Chrome\Application\chrome.exe
   C:\Program Files\Inkscape\inkscape.exe
   C:\Program Files\VideoLAN\VLC\vlc.exe

#>
function Get-Shortcut
{
    [CmdletBinding()]
    Param
    (
        # Use an existing shortcut to update the target.
        [Parameter(Mandatory=$true,
                   Position=0,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromPipeline=$true)]
        [string[]]
        $Path
    )

    Begin
    {
        $shell = New-Object -COM WScript.Shell
    }
    Process
    {
        $path | ForEach-Object {
            $shell.CreateShortcut(  (Get-Item $psitem).FullName  )
        }
    }
    End
    {
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($shell) > $null
        Remove-Variable shell
    }
}

<#
.Synopsis
   Change a shortcut property
.DESCRIPTION
   Bypass Windows GUI property validation when setting shortcut attributes.
   Allow a user to set a target path that does not exist for them.

   Useful for changing shortcuts that link to programs in shared folders that aren't mapped for the current user.
.EXAMPLE
   Set-Shortcut '.\TonerLog.lnk' -TargetPath "Q:\Printing\Toner Replacements.xlsx"
#>
function Set-Shortcut
{
    [CmdletBinding()]
    Param
    (
        # Shortcut location
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]
        $Path

        , # File path to target execution
        [Parameter(ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [string]
        $TargetPath = "C:\Program Files\"

        , # The "Comment" field under "Properties"
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [string]
        $Description

    )

    Begin
    {
        $shell = New-Object -COM WScript.Shell
    }
    Process
    {
        $item = Get-Item $Path
        $shortcut = $shell.CreateShortcut($item.FullName)  ## Open the lnk

        $shortcut.TargetPath = $TargetPath
        $shortcut.Description = $Description
        $shortcut.Save()
    }
    End
    {
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($shell) > $null
        Remove-Variable shell
    }
}