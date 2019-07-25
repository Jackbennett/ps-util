. (Join-Path $PSScriptRoot 'New-EasyPassword.ps1')
. (Join-Path $PSScriptRoot 'Get-FunctionDefaultParameter.ps1')

Describe "New-EasyPassword Functionality" {
    It "Error when making a password shorter than it is long" {
        { New-EasyPassword -MinLength 10 -MaxLength 5 } | Should -Throw
    }
    It "No Error when the min-max range is correct" {
        { New-EasyPassword -MinLength 5 -MaxLength 10 } | Should -Not -Throw
    }
    It "No Error specifying only the minimum length" {
        { New-EasyPassword -MinLength 5 } | Should -Not -Throw
    }
    It "No Error specifying only the maximum length" {
        { New-EasyPassword -MaxLength 8 } | Should -Not -Throw
    }
    It "No Error with maximum length lower than default minumum value" {
        { New-EasyPassword -MaxLength 4 } | Should -Not -Throw
    }
    It "Default parameters work without issue" {
        { New-EasyPassword } | Should -Not -Throw
    }
    It "Should return the correct password length" {
        1..100 |
        ForEach-Object {
            New-EasyPassword -MinLength 9 -MaxLength 10
        } |
        Where-Object length -ne 9 |
        Should -BeFalse
    }
    It "Prefix should respect maxLangth" {
        { New-EasyPassword -Prefix testing -MaxLength 2} | Should -Throw
    }
    It "Prefix should be exactly the length asked" {
        $result =  New-EasyPassword -Prefix testing -MinLength 10 -MaxLength 10

        $result.length | should -beExactly 10
    }
}

Describe "New-EasyPassword Aliases" {
    BeforeAll{
        $Default = Get-FunctionDefaultParameter -FunctionName 'New-EasyPassword'
    }
    It "Parameter aliases" {
        (New-EasyPassword -Min 4 -Max 5).length | Should -BeExactly 4
    }
    It "Positional Parameters" {
        (New-EasyPassword 4 5).length | Should -BeExactly 4
    }
    It "Works by Default" {
        $length = (New-EasyPassword).length
        $length | Should -BeGreaterOrEqual $Default.MinLength

        $minLength = $Default.MinLength
        $length | Should -BeLessOrEqual (Invoke-Expression($Default.MaxLength))
    }
}
