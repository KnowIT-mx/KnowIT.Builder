
function Get-KnowITModuleInfo {

    [Alias('moduleinfo')]
    param(
        [string]$Path = '.'
    )

    try {
        $rootFolder = Convert-Path $Path
        $buildModuleFile = Join-Path $rootFolder 'module.psd1'

        if(!(Test-Path $buildModuleFile -PathType Leaf)) {
            throw "Not found 'module.psd1' file in project folder [$rootFolder]"
        }

        $data = Import-PowerShellDataFile $buildModuleFile -ErrorAction Stop
        $data.ProjectFolder = $rootFolder
        $outDir = $data.OutputFolder ?? 'out'
        $data.OutputFolder = Join-Path $rootFolder $outDir $data.ModuleName
        $data
    }
    catch {
        Write-Error $_
    }
}