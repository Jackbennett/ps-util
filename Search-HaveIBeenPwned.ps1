function Search-HaveIBeenPwned {
    [CmdletBinding()]
    param (
        # SecureString of the password to look up
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [System.Security.SecureString[]]
        $Password = (Read-Host -Prompt "Password" -AsSecureString)

        , # Include the hashed password that was found, Command output will be in system logs therefor compromising some password security
        [switch]
        $IncludeHashes
    )

    begin {
        $security_before = [Net.ServicePointManager]::SecurityProtocol
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    }

    process {
        foreach ($pwd in $Password) {
            $stringBuilder = New-Object System.Text.StringBuilder
            [System.Security.Cryptography.HashAlgorithm]::Create("SHA1").ComputeHash(
                [System.Text.Encoding]::UTF8.GetBytes(
                    [Runtime.InteropServices.Marshal]::PtrToStringAuto(
                        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($pwd)
                    )
                )
            ).foreach({
                $stringBuilder.Append($_.ToString("x2")) > $Null
            })
            $hash = $stringBuilder.ToString().toUpper()
            $pass_object = [pscustomobject]@{
                short  = $hash.substring(0,5)
                hash   = $hash
                suffix = $hash.substring(5)
            }
            $response = Invoke-RestMethod -Method Get -Uri "https://api.pwnedpasswords.com/range/$($pass_object.short)" -ErrorAction Stop
            [string]$lookup = $response -split '\n' | Where-Object {
                $psitem.toUpper().startsWith($pass_object.suffix)
            }

            $output = [PSCustomObject]@{
                Index  = $Password.indexOf($pwd)
                Count  = [int]($lookup -split ':')[1]
            }
            if($lookup.length -eq 0){
                $output | Add-Member -NotePropertyName Secure -NotePropertyValue $True -Force
            } else {
                $output | Add-Member -NotePropertyName Secure -NotePropertyValue $False -Force
            }
            if($IncludeHashes){
                $output | Add-Member -NotePropertyName Hash -NotePropertyValue $pass_object.Hash -Force
            }

            Write-Output $output
        }
    }

    end {
        [Net.ServicePointManager]::SecurityProtocol = $security_before
    }
}

