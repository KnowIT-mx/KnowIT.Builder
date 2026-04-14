@{
    ModuleName    = 'KnowIT.Builder'
    ModuleId      = 'd96aca93-5299-4999-bca4-2ab84d215f33'
    Description   = 'Module to help in the creation and building of new PowerShell Modules'
    Author        = 'José Ramón Aguilar'
    Version       = '0.6.x-prerelease'

    MergePSM      = $true
    PSSourceFiles = 'public', 'private'
    ExtraContent  = 'template'
    # ExternalModules = 'PlatyPS'

    # Optional Manifest parameters
    Manifest = @{
        Tags              = 'Build', 'Development'
        CompanyName       = 'KnowIT Soluciones'
        Copyright         = '(c) 2025 KnowIT Soluciones'
        ProjectUri        = 'https://github.com/KnowIT-mx/KnowIT.Builder'
        LicenseUri        = 'https://github.com/KnowIT-mx/KnowIT.Builder/blob/master/LICENSE'
        PowerShellVersion = 7.2
    }
}

