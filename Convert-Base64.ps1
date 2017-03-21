function ConvertTo-Base64 {
    [CmdletBinding()]
    [OutputType([String])]
    Param
    (
        # File to encode the contents of
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]
        $Path
    )

    Process{
        $Text = Get-content -raw -Path $Path
        $String = [Convert]::ToBase64String( [System.Text.Encoding]::UTF8.GetBytes($Text) )

        Write-Output $String
    }
}

function ConvertFrom-Base64 {
    [CmdletBinding()]
    [OutputType([String])]
    Param
    (
        # Base64 Encoded String to convert to text
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]
        $EncodedString
    )
    Process{
        $String = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($EncodedString))
        Write-Output $String
    }
}
