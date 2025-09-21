#region === .Source files ===
$moduleData = Get-KnowITModuleInfo (Split-Path $PSScriptRoot)
$sourceFolders = $moduleData.PSSourceFiles.ForEach({ Join-Path $PSScriptRoot $_ })
foreach($scriptFile in Get-ChildItem $sourceFolders -Filter '*.ps1' -Recurse) {
    Write-Debug "Dot sourcing file: $scriptFile..."
    . $scriptFile.FullName
}
#endregion

#region === Module initialization ===

#endregion




