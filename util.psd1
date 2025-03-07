#
# Module manifest for module 'util'
#
# Generated by: j.bennett
#
# Generated on: 16/07/2014
#

@{

    # Version number of this module.
    ModuleVersion     = '2.0.0'

    # ID used to uniquely identify this module
    GUID              = '85f59690-bdb3-4153-b52d-dea64184565a'

    # Author of this module
    Author            = 'Jack Bennett <message@jackben.net>'

    # Company or vendor of this module
    CompanyName       = 'Jack Bennett'

    # Copyright statement for this module
    Copyright         = '(c) 2025 Jack Bennett All rights reserved.'

    # Description of the functionality provided by this module
    Description       = 'Helper functions most commonly used day-to-day. Not all of these are authored by myself.'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '3.0'

    # Root module file
    RootModule        = 'util.psm1'

    # Name of the Windows PowerShell host required by this module
    # PowerShellHostName = ''

    # Minimum version of the Windows PowerShell host required by this module
    # PowerShellHostVersion = ''

    # Minimum version of Microsoft .NET Framework required by this module
    # DotNetFrameworkVersion = ''

    # Minimum version of the common language runtime (CLR) required by this module
    # CLRVersion = ''

    # Processor architecture (None, X86, Amd64) required by this module
    # ProcessorArchitecture = ''

    # Modules that must be imported into the global environment prior to importing this module
    # RequiredModules = @()

    # Assemblies that must be loaded prior to importing this module
    # RequiredAssemblies = @()

    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    # ScriptsToProcess = @()

    # Type files (.ps1xml) to be loaded when importing this module
    # TypesToProcess = @()

    # Format files (.ps1xml) to be loaded when importing this module
    FormatsToProcess  = @('util.Format.ps1xml')

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    # NestedModules = @()

    # Functions to export from this module
    FunctionsToExport = @(
        'Approve-Script',
        'ConvertFrom-Base64',
        'ConvertTo-Base64',
        'ConvertTo-ImageFormat',
        'Copy-MultiItem',
        'Enter-RemoteSession',
        'Get-CurrentUser',
        'Get-DriveFailure',
        'Get-FreeSpace',
        'Get-LogonHistory',
        'Get-Shortcut',
        'Get-StartTime',
        'Get-User',
        'Invoke-DscPullAndApply',
        'Move-Drive',
        'New-Directory',
        'New-EasyPassword',
        'New-Shortcut',
        'Remove-MultiDirectory',
        'Search-HaveIBeenPwned'
        'Set-FileTime',
        'Set-Shortcut',
        'Suspend-Computer',
        'Test-TCPConnection',
        'Watch-Here'
    )

    # Cmdlets to export from this module
    CmdletsToExport   = '*'

    # Variables to export from this module
    VariablesToExport = '*'

    # Aliases to export from this module
    AliasesToExport   = '*'

    # List of all modules packaged with this module
    # ModuleList = @()

    # List of all files packaged with this module
    # FileList = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess
    # PrivateData = ''

    # HelpInfo URI of this module
    # HelpInfoURI = ''

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''

}
