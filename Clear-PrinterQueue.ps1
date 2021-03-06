<#
.Synopsis
    Clear the printer queue of a computer
.DESCRIPTION
    Clear all documents in the printer queue on a target machine and restart the print service.
.EXAMPLE
    Clear-PrinterQueue COMPUTER
    WARNING: Waiting for service 'Print Spooler (Spooler)' to start...
#>
function Clear-PrinterQueue
{
    [CmdletBinding()]
    Param
    (
        # Target Computer
        [Parameter(Mandatory = $true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string[]]
        $ComputerName
    )

    foreach($name in $ComputerName){
        $service = Get-Service -Name Spooler -ComputerName $name | Stop-Service
        Get-ChildItem -path "\\$name\c$\Windows\System32\spool\PRINTERS\" -File | Remove-Item -Force
        $service | Restart-Service
    }

}
