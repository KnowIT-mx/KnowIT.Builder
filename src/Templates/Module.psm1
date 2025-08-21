
#region === .Source files ===
$moduleData = Get-ModuleInfo (Split-Pat $PSScriptRoot)
foreach($scriptFile in Get-ChildItem $moduleData.PSSourceFiles -Include '*.ps1' -Recurse) {
    Write-Debug "Dot sourcing file: $scriptFile..."
    . $scriptFile.FullName
}
#endregion

#region === Module initialization ===

#endregion




