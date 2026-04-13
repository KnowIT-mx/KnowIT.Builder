@{
    ModuleName    = 'KnowIT.Module'
    ModuleId      = '00000000-0000-0000-0000-000000000000'
    Description   = 'KnowIT Module'
    Author        = 'KnowIT'
    Version       = '0.0.1-beta'

    PSSourceFiles = 'public', 'private'
    ExtraContent  = '*.ps1xml'
    ExternalModules = ''

    # Optional Manifest parameters
    Manifest = @{
        PowerShellVersion = 7.4
        # FormatsToProcess  = 'KnowIT.Module.Format.ps1xml'
        # TypesToProcess    = 'KnowIT.Module.Types.ps1xml'
        CompanyName       = 'KnowIT Soluciones'
        Copyright         = '(c) 2026 KnowIT Soluciones'
        # ProjectUri        = ''
        # LicenseUri        = ''
        # Tags              = @()
    }
}

