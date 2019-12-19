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
    Get-FreeSpace  | Sort freepercent

    ComputerName ID VolumeName           Description               FileSystem  Free (GB) Size (GB) Free % Path
    ------------ -- ----------           -----------               ----------  --------- --------- ------ ----
    OFFICEPC     D:                      CD-ROM Disc                                   0         0
    OFFICEPC     P: Data                 Network Connection        NTFS             17.8       150  11.87 \\srv_program01\apps
    OFFICEPC     T: Shared               Network Connection        NTFS            145.4       900  16.16 \\srv_file02.srv.internal\Shared
    OFFICEPC     L: Shared               Network Connection        NTFS            145.4       900  16.16 \\srv_file02\Website
    OFFICEPC     O: Shared               Network Connection        NTFS            145.4       900  16.16 \\srv_file02\office
    OFFICEPC     G: Shared               Network Connection        NTFS            145.4       900  16.16 \\srv\fileServer\General
    OFFICEPC     Q: Shared               Network Connection        NTFS            145.4       900  16.16 \\srv_file02\Administrators
    OFFICEPC     C: srv Computer         Local Fixed Disk          NTFS            30.63    117.44  26.08
    OFFICEPC     S: Data                 Network Connection        NTFS            66.41    249.87  26.58 \\srv_mis01\sims
    OFFICEPC     W: Shared               Network Connection        NTFS           372.88    698.49  53.38 \\srv_file01\Students
    OFFICEPC     F: Space                Local Fixed Disk          NTFS           215.54    399.87   53.9
    OFFICEPC     H: Google Drive File... Local Fixed Disk          FAT32         1163.97   1862.64  62.49
    OFFICEPC     N: Home                 Network Connection        NTFS          1225.23   1862.64  65.78 \\srv_file02\home\administrators\USERNAME
    OFFICEPC     A: VM                   Local Fixed Disk          ReFS           238.16    299.81  79.44
    OFFICEPC     V: Files                Network Connection        ReFS            91.06     99.94  91.12 \\FileServer\All
.EXAMPLE
    Get-FreeSpace -Credential UserA -ComputerName SVR-FILE01, SVR-FILE02

    ComputerName ID VolumeName           Description               FileSystem  Free (GB) Size (GB) Free %
    ------------ -- ----------           -----------               ----------  --------- --------- ------
    SVR-FILE01     A:                      3 1/2 Inch Floppy Drive                       0         0
    SVR-FILE01     C: System               Local Fixed Disk          NTFS            51.07     74.66  68.41
    SVR-FILE01     D: Home                 Local Fixed Disk          NTFS          1124.65   1862.64  60.38
    SVR-FILE01     E: Shared               Local Fixed Disk          NTFS           372.88    698.49  53.38
    SVR-FILE01     F: Shadow Copies        Local Fixed Disk          ReFS           191.03    199.81  95.61
    SVR-FILE01     Z:                      CD-ROM Disc                                   0         0
    SVR-FILE02     A:                      3 1/2 Inch Floppy Drive                       0         0
    SVR-FILE02     C: System               Local Fixed Disk          NTFS            51.17     74.66  68.54
    SVR-FILE02     D: Home                 Local Fixed Disk          NTFS           1225.2   1862.64  65.78
    SVR-FILE02     E: Shared               Local Fixed Disk          NTFS            145.4       900  16.16
    SVR-FILE02     F: Shadow Copies        Local Fixed Disk          ReFS           198.21    199.81   99.2
    SVR-FILE02     Z:                      CD-ROM Disc                                   0         0
#>
function Get-FreeSpace
{
    [CmdletBinding(DefaultParameterSetName="Default")]
    [OutputType([psobject])]
    Param
    (
        # Target Systems
        [Parameter(ValueFromPipeline,
                   ValueFromPipelineByPropertyName,
                   Position=0)]
        [string[]]
        $ComputerName = 'localhost'

        , # Credential for Target Computers
        [Parameter(ValueFromPipelineByPropertyName)]
        [System.Management.Automation.PSCredential]
        $Credential

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

    }
    Process
    {
        $OpenedCimSession = New-CimSession -ComputerName $ComputerName -Credential:$Credential -ErrorAction "SilentlyContinue"

        $output = Get-CimInstance -CimSession $OpenedCimSession -ClassName 'Cim_LogicalDisk' |
            Add-Member -passthru -MemberType ScriptProperty -Name 'FreeGB'  -Value $free |
            Add-Member -passthru -MemberType ScriptProperty -Name 'SizeGB'  -Value $size |
            Add-Member -passthru -MemberType ScriptProperty -Name 'FreePercent' -Value $percent |
            Add-Member -passthru -MemberType AliasProperty  -Name 'ID'      -Value "DeviceID" |
            Add-Member -passthru -MemberType AliasProperty  -Name 'ComputerName' -Value "SystemName" |
            Add-Member -passthru -MemberType AliasProperty  -Name 'Path' -Value "ProviderName" |
            Select-Object @(
                'ComputerName'
                'ID'
                'VolumeName'
                'Description'
                'FileSystem'
                'FreeGB'
                'SizeGB'
                'FreePercent'
                'Path'
            )

        foreach($i in $output){
            $i.psObject.typeNames.Insert(0, 'JackBennett.util.sysinfo.disks')
        }

        Write-Output $output

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
