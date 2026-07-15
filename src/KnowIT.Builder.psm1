#using namespace System.Management.Automation
#norequires -Modules CimCmdlets

#region === .Source files ===
$moduleData = Import-PowerShellDataFile $PSScriptRoot/../module.psd1
$sourceFolders = $moduleData.PSSourceFiles.ForEach({ Join-Path $PSScriptRoot $_ })
foreach($scriptFile in Get-ChildItem $sourceFolders -Include '*.ps1' -Recurse) {
    Write-Debug "Dot sourcing file: $scriptFile..."
    . $scriptFile.FullName
}
#endregion

#region === Module initialization ===

$script:PSModuleRoot = $PSScriptRoot

# Alias for internal use only (not exported)
Set-Alias -Name Write-Build -Value Write-KnowITBuild 

#endregion