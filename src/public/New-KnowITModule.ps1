function New-KnowITModule {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [string]$Path = $PWD.Path
    )

    $ErrorActionPreference = 'Stop'

    try {
        $modulePath = Join-Path $Path $Name
        if(Test-Path $modulePath) {
            throw "Directory '$modulePath' already exists. Can't create a new module in an existing folder!"
        }
        $templatePath = Join-Path $PSModuleRoot 'template'
        Copy-Item $templatePath $modulePath -Recurse
        Rename-Item "$modulePath/src/Module.psm1" -NewName "$Name.psm1"
        Get-ChildItem $modulePath -Filter 'dot.*' | Rename-Item -NewName { $_.Name -replace 'dot.', '.' }

        $moduleData = Import-PowerShellDataFile $templatePath/module.psd1
        $moduleData.ModuleName = $Name
        $moduleData.ModuleId = New-Guid

        $moduleFileContent = Get-Content $templatePath/module.psd1 -Raw
        ReplaceModuleData $moduleFileContent $moduleData
        | Set-Content $modulePath/module.psd1 -Encoding utf8BOM -Force

        "Import-Module `$PSScriptRoot/src/$Name.psm1 -Force -DisableNameChecking"
        | Set-Content $modulePath/run.ps1 -Encoding utf8BOM

        $gitCommand = Get-Command git -CommandType Application -ErrorAction Ignore
        if($gitCommand -and !$SkipGitInit) {
            Push-Location $modulePath
            & $gitCommand init
            & $gitCommand add . 2>&1 | Where-Object { $_ -notlike 'warning: *' }
            Pop-Location
        }
    }
    catch {
        $PSCmdlet.WriteError($_)
    }
}
