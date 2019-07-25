<#
.SYNOPSIS
    Generate a new password
.DESCRIPTION
    Create easy to read and type passwords for resetting accounts that exist for a short time.

    Randomly using and ascii table for a-Z, 1-9 with punctuation excluding ambiguous charaters like;
    O, 0, I, l, W, w, V v
.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does
.INPUTS
    None
.OUTPUTS
    String
.EXAMPLE
    New-EasyPassword -Prefix welcome -MinLength 12
    welcomevDVRm$
.EXAMPLE
    New-EasyPassword -MinLength 7
    ZzT:K.OG
#>
function New-EasyPassword{
    [CmdletBinding()]
    [OutputType([string])]
    Param(
        # Minimum Password Length
        [Parameter(Position=0)]
        [ValidateRange(1, [int]::MaxValue)]
        [Alias('Min')]
        [int]
        $MinLength = 6

        , # Maximum Password Length
        [Parameter(Position=1)]
        [ValidateRange(2, [int]::MaxValue)]
        [Alias('Max')]
        [int]
        $MaxLength = $MinLength + 2
        
        , # Prefix to the generated password to meet length requirments but lower complexity for quick resets
        [Parameter(Position=2)]
        [string]
        $Prefix
    )
    # Define the password length to be just the max length if a range is otherwise undefined.
    if($PSBoundParameters.ContainsKey('MaxLength') -and -not $PSBoundParameters.ContainsKey('MinLength')){
        $MinLength = $MaxLength - 1
    }
    if($MinLength -gt $MaxLength){
        Throw [System.Management.Automation.ParameterBindingException]::New("Max length($MaxLength) must be greater than the Minimum($MinLength)")
    }
    if($Prefix.length -ge $MinLength){
        Throw [System.Management.Automation.ParameterBindingException]::New("Prefix($Prefix) must be not be longer than the Minimum($MinLength) to add random characters")
    }
    
    if($Prefix){
        $MinLength -= $Prefix.length
        $MaxLength -= $Prefix.length
    }

    if($MinLength -eq $MaxLength){
        $length = $MinLength
    } else {
        $length = Get-Random -Minimum $MinLength -Maximum $MaxLength
    }

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

    Write-Output "$Prefix$(-join $letters)"
}
