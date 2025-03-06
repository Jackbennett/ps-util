<#
.SYNOPSIS
    Test a given path if it is accessible
.DESCRIPTION
    This cmdlet returns an object that contains the path that was tested to easily find failing paths.
.EXAMPLE

.EXAMPLE
    New-ComputerList u04 (2..10) -unc | %{ $_.path + 'printerConfig' } | Test-MultiPath

    Test Path
    ---- ----
    True \\u04PC02\c$\printerConfig
    True \\u04PC03\c$\printerConfig
    True \\u04PC04\c$\printerConfig
    True \\u04PC05\c$\printerConfig
    True \\u04PC06\c$\printerConfig
    True \\u04PC07\c$\printerConfig
    True \\u04PC08\c$\printerConfig
    True \\u04PC09\c$\printerConfig
    True \\u04PC10\c$\printerConfig
.EXAMPLE
    New-ComputerList u04 (2..4) -unc | Copy-MultiItem '\\u04pc01\c$\printerConfig' -passthru | Test-Multipath

    Test Path
    ---- ----
    True \\u04PC02\c$\printerConfig
    True \\u04PC03\c$\printerConfig
    True \\u04PC04\c$\printerConfig
.EXAMPLE
    Copy-MultiItem '\\u04pc01\c$\LOCAL.PRT' (New-ComputerList -Room u04 -computer (2..10) -unc).path -passThru | Test-Multipath

    Test Path
    ---- ----
    True \\u04PC02\c$\LOCAL.PRT
    True \\u04PC03\c$\LOCAL.PRT
    True \\u04PC04\c$\LOCAL.PRT
    ...
.OUTPUTS
    Object containing the test result and the path tested.

#>
function Test-MultiPath {
    [CmdletBinding(PositionalBinding=$false,
                   ConfirmImpact='Medium')]
    [OutputType([PSCustomObject])]
    Param (
        # Specifies a path to be tested. Wildcard characters are permitted. If the path includes spaces, enclose it in quotation marks.
        [Parameter(Mandatory=$true,
                   Position=0,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Path
    )
    Process {
        $path | foreach {
            New-Object -TypeName PSCustomObject -property @{
                Test = Test-path $PSItem
                Path = $PSItem
            }
        }
    }
}
