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
    $data.OutputFolder = [IO.Path]::GetFullPath([IO.Path]::Combine($RootFolder, $outDir, $data.ModuleName))

    $data
}

function FindProjectRoot
{
    if(Test-Path 'module.psd1') {
        return $PWD.Path
    }
    $current = $PWD.Path
    while ($current) {
        if((Split-Path $current -Leaf) -eq 'src') {
           return Split-Path $current
        }
        $current = Split-Path $current
    }

    throw 'Project Root Folder not found!'
}

function ReplaceModuleData ([string[]]$Content, [hashtable]$Data)
{
    $Content -replace '(?:\#+\s*)?(\w+\s*)=\s*(.+)', {
        $key = $_.Groups[1].Value.Trim()
        if(!$Data.ContainsKey($key) -or $_.Groups[2].Value -eq '@{') {
            return $_.Value
        }

        $value = switch ($Data[$key]) {
            { $_ -is [int] -or $_ -is [double] } { $_ }
            { $_ -is [bool] } { $_ ? '$true' : '$false' }
            default { "'$_'" }
        }
        '{0}= {1}' -f $_.Groups[1].Value, ($value -join ', ')
   }
}