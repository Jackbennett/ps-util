<#
.Synopsis
    Find the system install and last boot dates
.DESCRIPTION
    Get an object for a target computers last
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Get-StartTime
{
    [CmdletBinding()]
    [OutputType([psObject])]
    Param
    (
        # Target computer name.
        [Parameter(ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string[]]
        $ComputerName = 'localhost',

        # Property names to get.
        [Parameter(Position=1)]
        [string[]]
        $property = @('InstallDate')
    )

    Begin
    {
        $property += 'CSName', 'LastBootUpTime'
    }
    Process
    {
        $object = $Computername | Get-CimInstance -ClassName win32_operatingsystem -Property $property | Select-Object $property
        $object | Add-Member -MemberType AliasProperty -Name 'ComputerName' -Value "CSName"
        $object |
            Add-Member -PassThru -MemberType 'ScriptProperty' -Name 'UpTime' -Value {
                '{0:d\.h\:mm\:ss}' -f (New-TimeSpan $this.lastBootUpTime)
            }
    }
    End
    {
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
            0  = "DDR 3"
            21 = "DDR-2"
            20 = "DDR"
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
            Name = "Computer Name"
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
