function FindCurrentPSM
{
    $psm = "$moduleName.psm1"
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

function ProcessSourceFolders
{
    Write-Build "  Processing source files in folders: ($($ModuleData.PSSourceFiles -join ', '))..."
    $sourceTable = @{}
    foreach($path in $ModuleData.PSSourceFiles) {
        $files = Get-ChildItem -Filter $path -Directory |
            Get-ChildItem -Filter '*.ps1' -Recurse
        if($path -eq 'public') {
            $sourceTable.Public = $files
        }
        else {
            $sourceTable.Private += $files
        }
    }
    $publicAst = foreach($source in $sourceTable.Public) {
        $ast = [Management.Automation.Language.Parser]::ParseFile($source.FullName, [ref]$null, [ref]$null)
        $ast.Find({ $args[0] -is [Management.Automation.Language.FunctionDefinitionAst] }, $false)
    }
    $sourceTable.PublicFunctions = @($publicAst.Name)
    $sourceTable.Aliases = @(
        $publicAst.Body.ParamBlock.Attributes.Where({
            $_.TypeName.Name -eq 'Alias' }).
            PositionalArguments.Value
    )
    $sourceTable
}