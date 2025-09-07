
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
        ValidateModuleData $data
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


function ValidateModuleData ([hashtable]$Data)
{
    $requiredKeys = 'ModuleName', 'Description', 'Version', 'PSSourceFiles'
    $requiredManifest = 'GUID', 'Author'

    $missingKeys =
        $requiredKeys.Where({ $_ -notin $Data.Keys }) +
        $requiredManifest.Where({ $_ -notin $Data.Manifest.Keys }).ForEach({ "Manifest.$_" })

    if($missingKeys) {
        throw "Missing required keys in module.psd1: ($($missingKeys -join ', '))"
    }
}