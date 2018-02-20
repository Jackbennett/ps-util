<#
.Synopsis
   Sign the given script
.DESCRIPTION
   Use the first certificate in the current users certificate personal store.
   Signs scripts with a timestamp such that certificate expiry does not halt script execution.
.EXAMPLE
   Approve-Script .\HelloWorld.ps1

   Sign the script `HelloWorld.ps1` with out default code signing key added to the user account
.EXAMPLE
   Get-ChildItem . | Approve-Script

   Sign everything in the current folder.
.EXAMPLE
   cp -PassThru .\HelloWorld.ps1 \\server\Deployment\ | Approve-Script

   Copy a script to a central location whilst signing it for other people to trust execution.
#>
function Approve-Script
{
    [CmdletBinding()]
    [OutputType([System.IO.FileInfo])]
    Param
    (
        # The script to sign
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [Alias('Name')]
        [String[]]
        $Path

        , # Path to the certificate store to use.
        $CertificateStore = "Cert:\CurrentUser\My"
        , # which certificate to use in the given store.
        $StoreIndex = 0
        , # Timestamp Service to fix the signature to a known point in Time
        $TimetampServer = 'http://timestamp.verisign.com/scripts/timstamp.dll'
    )

    Begin
    {
        # Do not leak the certificate into the session
        $private:cert

        try{
            $private:cert = (Get-ChildItem $CertificateStore -ErrorAction Stop)[$StoreIndex]
        }
        catch {
            Write-Error "Certificate not found in $CertificateStore at $StoreIndex"
        }
    }
    Process
    {
        $Path | Set-AuthenticodeSignature -Certificate $private:cert -TimestampServer $TimetampServer -IncludeChain all
    }
    End
    {

    }
}
