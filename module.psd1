@{
    ModuleName = 'KnowIT.Builder'
    Description = 'Module to help in the cration and building of new PowerShell Modules'
    Version = '0.0.1'

    PSSourceFiles   = 'Public', 'Private'
    AdditionalFiles = 'Templates'
    OutputFolder    = 'out'

    Manifest = @{
        Author = 'José Ramón Aguilar'
        CompanyName = 'KnowIT'
        Copyright = '(c) 2025 KnowIT Soluciones'
        ProjectUri = ''
        PowerShellVersion = 7.2
    }
}

