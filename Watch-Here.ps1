<#
.Synopsis
   Watch for new files
.DESCRIPTION
   Watch a target path for new files
.EXAMPLE
    Watch-Here -Wait
    The file 'test - Copy.txt' was Created at 06/12/2015 11:13:08
    The file 'New Text Document.txt' was Created at 06/12/2015 11:13:20
.EXAMPLE
    Watch-Here
    Id   Name       PSJobTypeName   State         HasMoreData   Location   Command
    --   ----       -------------   -----         -----------   --------   -------
    28   Created                    NotStarted    False                    ...
.EXAMPLE
    $Job = Watch-Here -Path 'C:\temp\Share\*' -Action { mv 'C:\temp\Share\*' 'C:\private'; write-host "Moved share to private" }
#>
function Watch-Here
{
    [CmdletBinding()]
    Param
    (
        # Specifies the path to watch
        [Parameter(ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $Path = $PSScriptRoot

        , # Specify a filesystem filter script
        [string]
        $Filter = "*"

        , # Event Type
        [ValidateSet("Created", "Changed", "Renamed", "Deleted")]
        [string]
        $EventName = "Created"

        , # Show events in the console
        [switch]
        $Wait

        , # Include Subdirectories
        [switch]
        $Recurse

        , # Action
        [scriptblock]
        $Action = {
            $Name = $Event.SourceEventArgs.Name
            $Type = $Event.SourceEventArgs.ChangeType
            $Time = $Event.TimeGenerated
            Write-Output "$Time`: $Type the file '$Name'"
        }
    )

    Begin
    {
        $event = Get-EventSubscriber -SourceIdentifier $EventName -ErrorAction SilentlyContinue
        if($event){
            Unregister-Event -SourceIdentifier $EventName -Confirm
        }

    }
    Process
    {
        $Watch = New-Object IO.FileSystemWatcher $Path, $Filter -Property @{
            IncludeSubdirectories = $Recurse
            NotifyFilter = [IO.NotifyFilters]'FileName, LastWrite'
        }

        $handler = Register-ObjectEvent -InputObject $watch -EventName $EventName -SourceIdentifier $EventName -Action $Action

        if($Wait)
        {
            <#
            Use try/finally to catch the script being killed with "Ctrl-C" and unregister the event listener.
            End {} Will not be called when ended this way.
            #>
            try     { Wait-Event       $EventName }
            finally { Unregister-Event $EventName }
        }
    }
    End
    {
        Write-Output $handler
    }
}
