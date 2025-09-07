function GetModuleFileData ([string]$RootFolder)
{
    $ErrorActionPreference = 'Stop'

    $RootFolder = Convert-Path $RootFolder
    $moduleFile = Join-Path $RootFolder 'module.psd1'

    if(!(Test-Path $moduleFile -PathType Leaf)) {
        throw "Not found 'module.psd1' file in project folder [$RootFolder]"
    }
    $data = Import-PowerShellDataFile $moduleFile -ErrorAction Stop

    $requiredKeys = 'ModuleName', 'ModuleId', 'Description', 'Author', 'Version', 'PSSourceFiles'
    $missingKeys = $requiredKeys.Where({ $_ -notin $data.Keys })
    if($missingKeys) {
        throw "Missing required keys in module.psd1: ($($missingKeys -join ', '))"
    }

    $data.ProjectFolder = $RootFolder
    $outDir = $data.OutputFolder ?? 'out'
    $data.OutputFolder = Join-Path $RootFolder $outDir $data.ModuleName

    $data
}