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
    [CmdletBinding(SupportsShouldProcess=$true)]
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
        Remove-Variable shell
    }
}