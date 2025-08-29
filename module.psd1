@{
    ModuleName      = 'KnowIT.Builder'
    Description     = 'Module to help in the creation and building of new PowerShell Modules'
    Version         = '0.1.1-beta'

    PSSourceFiles   = 'Public', 'Private'
    AdditionalFiles = 'Templates'

    Manifest = @{
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

