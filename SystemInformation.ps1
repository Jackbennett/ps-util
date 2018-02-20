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
        # Hide errors if session is empty when credential isn't used.
        $parameters.CimSession | Remove-CimSession -ErrorAction 'SilentlyContinue'
    }
}

<#
.Synopsis
   List free space and total sizes on selected machines.
.DESCRIPTION
   List free space and total sizes on selected machines.
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Get-FreeSpace
{
    [CmdletBinding()]
    [OutputType([psobject])]
    Param
    (
        # Target computer names
        [Parameter(ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $ComputerName = 'localhost'
    )

    Begin
    {
    }
    Process
    {
        $FreeSpace = @{
            name="FreeSpace (GB)"
            expression={
                [Math]::Round($_.freeSpace/1gb, 2)
            }
        }

        $Size = @{
            name="Size (GB)"
            expression={
                [Math]::Round($_.Size/1gb, 2)
            }
        }
        $SourceComputer = @{
            name="Computer Name"
            expression={
                $_.__SERVER
            }
        }

        Get-WmiObject `
            -Class win32_logicaldisk `
            -ComputerName $ComputerName `
            -ErrorAction SilentlyContinue `
            |
            select `
                $SourceComputer,
                deviceid,
                $FreeSpace,
                $Size `
                |
                Write-Output
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
function Get-Memory
{
    [CmdletBinding()]
    [OutputType([psobject])]
    Param
    (
        # Target computer names
        [Parameter(ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $ComputerName = 'localhost'
    )

    Begin
    {
        # Inconsistent notation to increase readability.
        $ListOfMemory = @{
            20 = "DDR"
            21 = "DDR 2"
            24 = "DDR 3" # Windows 10
            0  = "DDR 3" # Windows 7
        }

        $Speed = @{
            Name = "Speed (MHz)"
            Expression = {
                $_.Speed
            }
        }
        $Capacity = @{
            Name = "Capacity (MB)"
            Expression = {
                [Math]::Round( $_.Capacity / 1mb , 0)
            }
        }
        $SourceComputer = @{
            Name = "ComputerName"
            Expression={
                $_.__SERVER
            }
        }
        $MemoryType = @{
            Name = "Memory Type"
            Expression = {
                $ListOfMemory.Item([int]$_.MemoryType)
            }
        }

    }
    Process
    {
        Get-WmiObject `
            -class win32_PhysicalMemory `
            -ComputerName $ComputerName `
            |
            select `
                $SourceComputer,
                Manufacturer,
                PartNumber,
                $Speed,
                $Capacity,
                DeviceLocator,
                $MemoryType `
                |
                where { $_.DeviceLocator -notmatch "SYSTEM ROM" } `
                |
                Write-Output
    }
}
