
function Get-KnowITModuleInfo {

    [Alias('moduleinfo')]
    param(
        [string]$Path = '.'
    )

    try {
        $rootFolder = Convert-Path $Path
        $moduleFile = Join-Path $rootFolder 'module.psd1'

        if(!(Test-Path $moduleFile -PathType Leaf)) {
            throw "Not found 'module.psd1' file in project folder [$rootFolder]"
        }

        $data = Import-PowerShellDataFile $moduleFile -ErrorAction Stop
        $data.ProjectFolder = $rootFolder
        $outDir = $data.OutputFolder ?? 'out'
        $data.OutputFolder = Join-Path $rootFolder $outDir $data.ModuleName
        $data
        $null = ValidateVersion $data.Version
    }
    catch {
        Write-Error $_
    }
}