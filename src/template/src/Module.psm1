#region === .Source files ===
$moduleData = Get-KnowITModuleInfo (Split-Path $PSScriptRoot)
foreach($scriptFile in Get-ChildItem $moduleData.PSSourceFiles -Filter '*.ps1' -Recurse) {
    Write-Debug "Dot sourcing file: $scriptFile..."
    . $scriptFile.FullName
}
#endregion

#region === Module initialization ===

#endregion




