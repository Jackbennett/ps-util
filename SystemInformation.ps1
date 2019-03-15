<#
.Synopsis
    Find system properties like install, last boot date calculates uptimes
.DESCRIPTION
    Get objects containing boot times or additionally specified operating system properties.

    Other usefull properties;
    Catption - Operating system version name
    Version - OS Number

    Also see, Get-Memory
.EXAMPLE
    Get-StartTime -Credential $cred -ComputerName $onlineList | sort uptime | ft

    Get a useful table of machines in your org.

    InstallDate         CSName LastBootUpTime      ComputerName UpTime               UpTimeMessage
    -----------         ------ --------------      ------------ ------               -------------
    21/08/2013 11:21:09 BKS01  10/01/2018 06:56:32 BKS01        04:08:38.9171087     0 Days 4 Hours 8 Minutes
    16/08/2013 17:06:23 AVS01  10/01/2018 02:51:48 AVS01        08:13:22.4822857     0 Days 8 Hours 13 Minutes
    16/08/2013 17:42:26 FS01   10/01/2018 02:34:12 FS01         08:30:59.3236737     0 Days 8 Hours 30 Minutes
    16/08/2013 17:46:34 WDS01  10/01/2018 02:25:52 WDS01        08:39:19.2876961     0 Days 8 Hours 39 Minutes
.EXAMPLE
    Get-StartTime -Credential $cred -ComputerName $onlineList

    InstallDate    : 20/08/2013 13:20:10
    CSName         : PS01
    LastBootUpTime : 31/10/2017 01:19:03
    ComputerName   : PS01
    UpTime         : 71.09:16:06.3147368
    UpTimeMessage  : 71 Days 9 Hours 16 Minutes

    InstallDate    : 16/08/2013 17:46:34
    CSName         : WDS01
    LastBootUpTime : 10/01/2018 02:25:52
    ComputerName   : WDS01
    UpTime         : 08:09:17.2712937
    UpTimeMessage  : 0 Days 8 Hours 9 Minutes
#>
function Get-StartTime
{
    [CmdletBinding()]
    [OutputType([psObject])]
    Param
    (
        # Target computer name.
        [Parameter(Position=0,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [Parameter(ParameterSetName='Remote',
                   Position=0,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [parameter(ParameterSetName='Cred',
                   Mandatory,
                   Position=0,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string[]]
        $ComputerName,

        # Value names to fetch.
        [Parameter(Position=1)]
        [string[]]
        $Property = @('InstallDate'),

        # Identity to use
        [parameter(ParameterSetName='Cred')]
        [System.Management.Automation.PSCredential]
        $Credential
    )

    Begin
    {
        $Property += @('CSName', 'LastBootUpTime')
        $parameters = @{
            ClassName = 'win32_operatingSystem'
            Property = $Property | Select-object -Unique
            ErrorAction = 'Stop'
        }
        switch($PsCmdlet.ParameterSetName){
            "Cred" {
                $parameters.CimSession = New-CimSession -ComputerName $ComputerName -Credential $Credential
            }
            "Remote" {
                $parameters.CimSession = $ComputerName | New-CimSession
            }
        }
    }
    Process
    {
        $object = Get-CimInstance @parameters | Select-Object $property
        $object | Add-Member -MemberType 'AliasProperty' -Name 'ComputerName' -Value "CSName"
        $object | Add-Member -MemberType 'ScriptProperty' -Name 'UpTime' -Value {
                New-TimeSpan $this.lastBootUpTime
            }
        $object | Add-Member -MemberType 'ScriptProperty' -Name 'UpTimeMessage' -Value {
                '{0} Days {1} Hours {2} Minutes' -f $this.UpTime.Days, $this.UpTime.Hours, $this.UpTime.Minutes
            }
        Write-Output $object
    }
    End
    {
        # Remove opened session that collected information.
        # Hide errors if session is empty when Credential isn't used.
        $parameters.CimSession | Remove-CimSession -ErrorAction 'SilentlyContinue'
    }
}

<#
.Synopsis
    List free space and total sizes on selected machines.
.DESCRIPTION
    Get all disk information available from specified computers
.EXAMPLE
    Get-FreeSpace

    ComputerName ID ProviderName                                   FreeGB  SizeGB Percent
    ------------ -- ------------                                   ------  ------ -------
    ThisComputer A:                                                 188.3  299.81    62.8
    ThisComputer C:                                                 66.81  117.57   56.83
    ThisComputer D:                                                267.59  399.87   66.92
    ThisComputer E:                                                     0       0
    ThisComputer G: \\Server1\shared$                               66.99  698.49    9.59
    ThisComputer L: \\Server1\Project$                              66.99  698.49    9.59
    ThisComputer M: \\Server2\manage$                               70.53     100   70.53
    ThisComputer N: \\Server1\home$\users\name...                 1396.35 1862.64   74.97
    ThisComputer O: \\Server1\office$                               66.99  698.49    9.59
    ThisComputer P: \\Server3\programs$                             26.89     150   17.93
    ThisComputer Q: \\Server4\secret$                               66.99  698.49    9.59
    ThisComputer S: \\Server5\application                           18.61     200     9.3
    ThisComputer T: \\Server4\staff$                                66.99  698.49    9.59
    ThisComputer V: \\Server6\work$                               1144.24 1862.64   61.43
    ThisComputer W: \\Server6\work2$                               434.53  698.49   62.21
    ThisComputer X: \\Server4\shortcut$                           1396.35 1862.64   74.97
#>
function Get-FreeSpace
{
    [CmdletBinding(DefaultParameterSetName="Default")]
    [OutputType([psobject])]
    Param
    (
        # Target Systems
        [Parameter(ValueFromPipelineByPropertyName=$true,
                   Position=0,
                   Mandatory,
                   ParameterSetName='Credential')]
        [string[]]
        $ComputerName = 'localhost'

        , # Credential for Target Computers
        [Parameter(ValueFromPipelineByPropertyName=$true,
                   ParameterSetName='Credential')]
        [System.Management.Automation.PSCredential]
        $Credential

        , # Existing Sessions to query
        [Parameter(ValueFromPipelineByPropertyName=$true,
                   ParameterSetName='Default')]
        [Microsoft.Management.Infrastructure.CimSession[]]
        $CimSession
    )

    Begin
    {
        $free = {
            [Math]::Round($this.freeSpace/1gb, 2)
        }
        $size = {
            [Math]::Round($this.Size/1gb, 2)
        }
        $percent = {
            [Math]::Round($this.FreeSpace/$this.Size * 100, 2)
        }

        if($ComputerName) {
            $OpenedCimSession = New-CimSession -ComputerName $ComputerName -Credential:$Credential -ErrorAction Stop
        }
    }
    Process
    {
        $params = @{
            ClassName = 'Win32_LogicalDisk'
        }
        if($OpenedCimSession){
            $Params.CimSession = $OpenedCimSession
        }
        if($CimSession){
            $Params.CimSession = $CimSession
        }

        $output = Get-CimInstance @params |
            Add-Member -passthru -MemberType ScriptProperty -Name 'FreeGB'  -Value $free |
            Add-Member -passthru -MemberType ScriptProperty -Name 'SizeGB'  -Value $size |
            Add-Member -passthru -MemberType ScriptProperty -Name 'Percent' -Value $percent |
            Add-Member -passthru -MemberType AliasProperty  -Name 'ID'      -Value "DeviceID" |
            Add-Member -passthru -MemberType AliasProperty  -Name 'ComputerName' -Value "SystemName" |
            Select-Object * -ExcludeProperty PSComputername

        foreach($i in $output){
            $i.psObject.typeNames.Insert(0, 'JackBennett.util.sysinfo.disks')
        }

        Write-Output $output

    }
    end{
        $OpenedCimSession | Remove-CimSession
    }
}

<#
.Synopsis
    Show the memory configuration
.DESCRIPTION
    Use a WMI query to show the current memory configuration of the target computer
.EXAMPLE
    Get-Memory

    Computer Name : TECH-02
    Manufacturer  : Corsair
    Speed (MHz)   : 1600
    Capacity (MB) : 4096
    DeviceLocator : DIMM 1
    Memory Type   : DDR 3

    Get a list of the memory configuration of the `localhost` computer
.EXAMPLE
    get-memory -ComputerName 50-02 | format-table -autosize

    Computer Name Manufacturer                     Speed (MHz) Capacity (MB) DeviceLocator Memory Type
    ------------- ------------                     ----------- ------------- ------------- -----------
    50-02         JEDEC ID:7F 7F FE 00 00 00 00 00         667          1024 XMM2          DDR-2
    50-02         JEDEC ID:7F 7F 7F 0B 00 00 00 00         667          1024 XMM4          DDR-2

    Get the memory configuration of a remote computer formatted in an easy to read way
.EXAMPLE
    get-memory | select 'computer name','capacity (MB)'

    Computer Name Capacity (MB)
    ------------- -------------
    TECH-02                4096

    Select specific fields from the dataset. Number of fields 4 or below automatically formats as a table.
#>
