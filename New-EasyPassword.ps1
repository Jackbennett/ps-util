function New-EasyPassword($MinLength = 5, $MaxLength = 8){
    $length = Get-Random -Minimum $MinLength -Maximum $MaxLength

    $letters = (33..122) | 
        Where-Object {
            # Using an ASCII table, exclude character numbers found hard to say or type.
            # Consider removing O, 0, I, l, W, w, V v if you can't control the font the user is presented with.
            $psitem -notin 34, 38, 39, 42, 44, 47, 60, 62 + 91..96
        } |
        Get-Random -Count $length |
        ForEach-Object {
            [char]$psitem
        }

    Write-Output (-join $letters)
}
