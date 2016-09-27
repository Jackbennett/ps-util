<#
.Synopsis
   Create a computer list given a room name and computer number
.DESCRIPTION
   Will create a computer list given a room name and computer number without verifying if these names exist in the network.

   Pipeline output is an object with properties computerName

.EXAMPLE
   New-ComputerList -Room 50 -Computer (8..11)

    ComputerName
    ------------
    50PC08
    50PC09
    50PC10
    50PC11
.EXAMPLE
    New-ComputerList 40 -Computer 2,3,4,10 | Invoke-Command { ... }

    Pipe the computer name into a remote execution command.
.EXAMPLE
    New-ComputerList o16 (1..10) -unc g

    ComputerName
    ------------
    \\o16PC01\g$\
    \\o16PC02\g$\
    \\o16PC03\g$\
    \\o16PC04\g$\
    \\o16PC05\g$\
    \\o16PC06\g$\
    \\o16PC07\g$\
    \\o16PC08\g$\
    \\o16PC09\g$\
    \\o16PC10\g$\
#>
function New-ComputerList
{
    [CmdletBinding(DefaultParameterSetName='Name')]
    [OutputType([String])]
    Param
    (
        # Room number
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string[]]
        $Room

        , # Start PC number, default is 1. leading zero is unnecessary
        [Parameter(Position=1)]
        [int[]]
        $Computer = 1

        , # Return a Full Qualified Domain name
        [Parameter(ParameterSetName='Name')]
        [switch]
        $FQDN = $false

        , # Return a UNC Path
        [Parameter(ParameterSetName='File Path')]
        [switch]
        $UNC

        , # Drive letter
        [Parameter(ParameterSetName='File Path',
                   Position=2)]
        [ValidateSet('a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z')]
        [string]
        $Drive = 'c'
    )

    Begin
    {
        #What's the fully qualified domain name in case we need it
        $domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().name
    }

    Process
    {
        # We need to build the string ROOM-COMPUTER
        
        # So for each room we've been given
        foreach($r in $room){
            Write-Verbose "Making list for Room: $r"

            # Make a computer for each of the computers specified
            foreach($c in $computer){
                Write-Verbose "adding computer: $c to the room list"
                # Add this string to our list of computernames with a fully qualified domain name
                $computerName = "$r`PC$( $c.toString('00') )"

                if($FQDN)
                {
                    Write-Verbose ('Adding FQDN [' + $domain + '] to ' + $computerName + ' computer')
                    New-Object -TypeName psobject -Property @{"ComputerName" = $computerName += ".$domain"}
                }

                if($UNC){
                    New-Object -TypeName psobject -Property @{"Path" = "\\$computerName\$Drive$\"}
                }
            }
        }
    }
}