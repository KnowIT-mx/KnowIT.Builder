function ProcessSourceFolders ($ModuleData)
{
    Write-Build "Processing source files in folders: ($($ModuleData.PSSourceFiles -join ', '))..."
    $ModuleData.PublicFiles = @()
    $ModuleData.PrivateFiles = @()

    foreach($path in $ModuleData.PSSourceFiles) {
        $files = Get-ChildItem -Filter $path -Directory |
            Get-ChildItem -Filter '*.ps1' -Recurse
        if($path -eq 'public') {
            $ModuleData.PublicFiles = $files
        }
        else {
            $ModuleData.PrivateFiles += $files
        }
    }
    $publicAst = foreach($source in $ModuleData.PublicFiles) {
        $ast = [Management.Automation.Language.Parser]::ParseFile($source.FullName, [ref]$null, [ref]$null)
        $ast.Find({ $args[0] -is [Management.Automation.Language.FunctionDefinitionAst] }, $false)
    }
    $ModuleData.PublicFunctions = $publicAst.Name
    $ModuleData.Aliases = $publicAst.Body.ParamBlock.Attributes.
        Where({ $_.TypeName.Name -eq 'Alias' }).
        PositionalArguments.Value

    Write-Build "  Found $($ModuleData.PublicFunctions.Count) public functions and $($ModuleData.Aliases.Count) aliases"
    Write-Build
}

function FindCurrentPSM ([string]$ModuleName)
{
    $psm = "$ModuleName.psm1"
    if(Test-Path $psm -PathType Leaf) {
        return $psm
    }

    $files = Get-Item *.psm1
    if(!$files) {
        throw 'No existing .psm1 file found!'
    }
    if($files.Count -gt 1) {
        throw "Found $($files.Count) .psm1 files! Can't merge multiple files."
    }
    return $files.Name
}