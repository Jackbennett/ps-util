function ConvertTo-PDF{
    <#
    .SYNOPSIS
        Convert an office file to a PDf
    .DESCRIPTION
        Invoking the builtin office "save as" feature to create a pdf

        currently will only handle word docx files.
    .EXAMPLE
        PS C:\> ls .\test\ -filter "*.docx" | ConvertTo-PDF
        Explanation of what the example does
    .INPUTS
        System.IO.FileInfo
    .OUTPUTS
        System.IO.FileInfo
    .NOTES
        General notes
    #>
    Param(
        # Source files
        [Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [System.IO.FileInfo[]]
        $Path
    )
    Begin {
        $word = New-Object -ComObject WORD.APPLICATION
    }
    Process{
        $Path |
            foreach-object {
                $newname = $psitem.fullname.replace('docx', 'pdf')
                if (test-path $newname) {
                    write-warning "PDF Already exists in: $newname"
                    return
                }
                $handle = $word.Documents.Open($psitem.fullname)
                $handle.saveas([ref]$newname, [ref]17)
                Write-Output (Get-item $newname)
                $handle.close()
            }
    }
    End{
        $word.quit()
    }

}
