. (Join-Path $PSScriptRoot 'New-EasyPassword.ps1')

Describe "New-EasyPassword" {
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

}
