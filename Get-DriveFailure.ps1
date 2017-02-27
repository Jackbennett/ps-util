Function Get-DriveFailure {
    <#
    .SYNOPSIS
        Get drives that are signaling failure
    .DESCRIPTION
        Only returns drives that signal impending failure in your organisation

        As such, No news is good news.
    .EXAMPLE
        PS C:\> Get-DriveFailure
        ComputerName   Failure Reason DeviceId
        -------------- ------- ------ --------
        ITSPC02          False      0 SCSI\Disk&Ven_SanDisk&Prod_________\_&________&_&_____
        ITSPC02          False      0 SCSI\Disk&Ven_TOSHIBA&Prod_________\_&________&_&_____

        Show all drives status
    .EXAMPLE
        Get-DriveFailure itspc04
        ComputerName Failure Reason DeviceId
        ------------ ------- ------ --------
        ITSPC04        False      0 SCSI\Disk&Ven_SanDisk&Prod_______\_______
        ITSPC04        False      0 SCSI\Disk&Ven_Corsair&Prod_Force_3_SSD\_______

        Show all drives status of a remote computer
    .EXAMPLE
        New-ComputerList u04 (1..10)  | Get-DriveFailure | where failure

        Get only the drives marked with predicted failure for the first 10 computers in a room.
    .EXAMPLE
        PS C:\> Get-DriveFailure | where Failure -eq $True

        Filter where drives are failed
    .INPUTS
        [string[]]
        Strings of computer names to query
    .OUTPUTS
        Object containing; source computer, Predicted failure status, Reason for failed drives, and the DeviceId of the drive.
    .NOTES
        General notes
    #>
    Param(
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string[]]
        $ComputerName = 'localhost'
    )
    Process{
        Get-WmiObject -ComputerName $Computername -namespace root\wmi -class MSStorageDriver_FailurePredictStatus |
            Select-Object @{
                n='ComputerName'
                e={$_.PSComputername}
            },
            @{
                n='Failure'
                e={$_.PredictFailure}
            },
            Reason,
            @{
                n='DeviceId'
                e={$_.InstanceName}
            }
    }
}