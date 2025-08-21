#region === .Source files ===
$moduleData = Import-PowerShellDataFile $PSScriptRoot/../module.psd1
$sourceFiles = $moduleData.PSSourceFiles.ForEach({ "$PSScriptRoot/$_" })
foreach($scriptFile in Get-ChildItem $sourceFiles -Include '*.ps1' -Recurse) {
    Write-Debug "Dot sourcing file: $scriptFile..."
    . $scriptFile.FullName
}
#endregion
