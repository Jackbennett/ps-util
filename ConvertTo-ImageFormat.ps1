function ConvertTo-ImageFormat {
[CmdletBinding()]
param
(    [Parameter(Mandatory=$True,
ValueFromPipeline=$false)]
[string[]]$path,
[string[]]$oldext,
[validateset(“bitmap”,”emf”,”exif”,”gif”,”icon”,”jpeg”,”png”,”tiff”,”wmf”)]
[string[]]$format
)
begin {
if((Test-Path -Path $path))
{
}
Else
{
Write-Warning “Path doesn’t exist – error”
Return
}
$files=Get-ChildItem $path |where-object {$_.Extension -eq $oldext}
$newext =””

switch($format)
{
“bitmap”{$newext =”.bmp”;}
“emf”{$newext =”.emf”;}
“exif”{$newext =”.exif”}
“gif”{$newext =”.gif”}
“icon”{$newext =”.ico”;}
“jpeg”{$newext =”.jpg”}
“png”{$newext =”.png”}
“tiff”{$newext =”.tif”}
“wmf”{$newext =”.wmf”}
}

}
 process {
foreach ($file in $files) {
Write-Verbose “Processing $file to convert to $format”
$newimage = new-object System.Drawing.Bitmap($file.FullName);
$newfile = Join-Path -Path $file.directory -ChildPath ($file.BaseName + $newext)

      if(!(Test-Path -Path $newfile))
{
switch($format)
{
“bitmap”{$newimage.Save($newfile,”bmp”);}
“emf”{$newimage.Save($newfile,”emf”);}
“exif”{$newimage.Save($newfile,”exif”);}
“gif”{$newimage.Save($newfile,”gif”);}
“icon”{$newimage.Save($newfile,”icon”);}
“jpeg”{$newimage.Save($newfile,”jpeg”);}
“png”{$newimage.Save($newfile,”png”);}
“tiff”{$newimage.Save($newfile,”tiff”);}
“wmf”{$newimage.Save($newfile,”wmf”);}
}
}
else
{
write-warning “$newfile already exists”
}

$newimage.Dispose()

}
}