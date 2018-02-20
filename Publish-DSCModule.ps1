function Publish-DSCResource {
    Param(
        [Parameter(Mandatory)]
        [string[]]
        $Name

        , # Desitnation Pull Server
        [Parameter(Mandatory, ParameterSetName='Auth')]
        [string]
        $ComputerName

        , # Connection credentials
        [Parameter(Mandatory, ParameterSetName='Auth')]
        [System.Management.Automation.PSCredential]
        $Credential = (Get-Credential)

        , # Server connection
        [Parameter(ParameterSetName='Session')]
        [System.Management.Automation.PSCredential]
        $Session

        , # Type of resource
        [Parameter(Mandatory)]
        [ValidateSet('Configuration','Module')]
        [string]
        $Type
    )
    Begin{
        if(-not $session){
            $session = New-pssession -computername $computername -Credential $Credential -ErrorAction Stop
        }
    }
    Process {
        switch($Type){
            'Configuration' {
                $ServerPath = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration\"
                New-DscChecksum -Path $Name
                break
            }
            'Module' {
                $ServerPath = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Modules\"
                $Version = (Get-Module $Name -ListAvailable).Version
                $ModulePath = (Get-Module $Name -ListAvailable).modulebase + '\*'
                $DestinationPath = Join-Path $env:temp "$($Name)_$($Version).zip"
                Compress-Archive -Path $ModulePath -DestinationPath $DestinationPath
                New-DscChecksum -Path $DestinationPath
                break
            }
        }
        
        

        copy-Item -ToSession $session -Destination $ServerPath -Path @(
            $DestinationPath,
            $DestinationPath + '.checksum'
        )

    }


}
