<#
.Synopsis
   Convert between image formats
.DESCRIPTION
   Convert between image formats with the Windows Forms library.
.INPUTS
   Image Files
.OUTPUTS
   Image Files
.NOTES
   credit: Hazzy, http://hazzy.techanarchy.net/posh/powershell/bmp-to-jpg-the-powershell-way/
.FUNCTIONALITY
   Convert between image formats.
#>
function ConvertTo-ImageFormat {
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory=$True,
            ValueFromPipeline=$false
        )]
        [string[]]
        $Path

        , [string[]]
        $oldext

        , [validateSet("bitmap","emf","exif","gif","icon","jpeg","png","tiff","wmf")]
        [string[]]
        $format
    )
    begin {
        if( -not (Test-Path -Path $path)){
            Throw "Path doesn’t exist – error"
        }

        $files = Get-ChildItem $path | where-object {$_.Extension -eq $oldext}
        $newext = ""

        switch($format){
            "bitmap" {$newext = ".bmp"  }
            "emf"    {$newext = ".emf"  }
            "exif"   {$newext = ".exif" }
            "gif"    {$newext = ".gif"  }
            "icon"   {$newext = ".ico"  }
            "jpeg"   {$newext = ".jpg"  }
            "png"    {$newext = ".png"  }
            "tiff"   {$newext = ".tif"  }
            "wmf"    {$newext = ".wmf"  }
        }

    }
    process {
        foreach ($file in $files) {
            Write-Verbose "Processing $file to convert to $format"
            $newimage = new-object System.Drawing.Bitmap($file.FullName);
            $newfile = Join-Path -Path $file.directory -ChildPath ($file.BaseName + $newext)

            if(-not (Test-Path -Path $newfile)){
                switch($format){
                    "bitmap" {$newimage.Save($newfile,"bmp" );}
                    "emf"    {$newimage.Save($newfile,"emf" );}
                    "exif"   {$newimage.Save($newfile,"exif");}
                    "gif"    {$newimage.Save($newfile,"gif" );}
                    "icon"   {$newimage.Save($newfile,"icon");}
                    "jpeg"   {$newimage.Save($newfile,"jpeg");}
                    "png"    {$newimage.Save($newfile,"png" );}
                    "tiff"   {$newimage.Save($newfile,"tiff");}
                    "wmf"    {$newimage.Save($newfile,"wmf" );}
                }
            }
            else{
                write-warning "$newfile already exists"
            }

            $newimage.Dispose()

        }
    }
}