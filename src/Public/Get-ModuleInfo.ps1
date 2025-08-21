
function Get-ModuleInfo {
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
        $data.OutputFolder = Join-Path $rootFolder $data.OutputFolder
        $data.PSSourceFiles = $data.PSSourceFiles.ForEach({ Join-Path $rootFolder 'src' $_ })
        $data
    }
    catch {
        Write-Error $_
    }
}