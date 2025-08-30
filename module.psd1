@{
    ModuleName    = 'KnowIT.Builder'
    Description   = 'Module to help in the creation and building of new PowerShell Modules'
    Version       = '0.0.x-beta'

    PSSourceFiles = 'public', 'private'
    ExtraContent  = 'templates'
    # ExternalModules = 'PlatyPS'

    Manifest = @{
        GUID              = 'd96aca93-5299-4999-bca4-2ab84d215f33'
        Author            = 'José Ramón Aguilar'
        CompanyName       = 'KnowIT'
        Copyright         = '(c) 2025 KnowIT Soluciones'
        ProjectUri        = 'https://github.com/JoseRa-KnowIT/KnowIT.Builder'
        PowerShellVersion = 7.2
        PrivateData = @{
            Builder = 'KnowIT'
        }
    }
}

