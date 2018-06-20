function New-EasyPassword{
    [CmdletBinding()]
    Param(
        # Minimum Password Lenght
        [Parameter(Position=0)]
        [ValidateRange(1, [int]::MaxValue)]
        [Alias('Min')]
        $MinLength = 6

        , # Maximum Password Lenght
        [Parameter(Position=1)]
        [ValidateRange(2, [int]::MaxValue)]
        [Alias('Max')]
        $MaxLength = $MinLength + 2
    )
    if($PSBoundParameters.ContainsKey('MaxLength') -and -not $PSBoundParameters.ContainsKey('MinLength')){
        $MinLength = $MaxLength - 1
    }
    if($MinLength -ge $MaxLength){
        Throw [System.Management.Automation.ParameterBindingException]::New("Max length($MaxLength) must be greater than the Minimum($MinLength)")
    }

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
