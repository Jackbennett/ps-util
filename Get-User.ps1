<#
.Synopsis
    Get the currently logged in user of the target computer
.DESCRIPTION
    Create a list of the users currently logged onto a given amount of computers.

    Very useful for quickly getting a class list to then use for filtering or reporting actions.
.EXAMPLE
    Get-User

    Name    Username    
    ----    --------    
    ITSPC02 Contoso\exampleUser
.EXAMPLE
    New-ComputerList -Room U05 -Computer (1..4) | Get-User

    Name    Username            
    ----    --------            
    U05PC01 BHS\smoss           
    U05PC02 BHS\15gray-rollingso
    U05PC03 BHS\15blacke        
    U05PC04 BHS\15selbyT   
#>
function Get-User
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        # Target Computer Name
        [Parameter(ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string[]]
        $ComputerName = 'localhost'
    )

    Get-WMIObject -ComputerName $ComputerName -class Win32_ComputerSystem -Property username,name | select Name,Username

}