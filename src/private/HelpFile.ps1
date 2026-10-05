function BuildHelpFile ($ModuleData)
{
    $moduleName = $ModuleData.ModuleName
    Write-Build "Building Help File: '$moduleName-Help.xml'..."

    AssertPlatyPSModule
    $docsPath = $ModuleData.DocsFolder
    $outputFolder = Split-Path $ModuleData.OutputFolder

    $mdFiles = Get-ChildItem -Path $docsPath -Filter '*.md' -File -ErrorAction SilentlyContinue
    if(!$mdFiles -or $mdFiles.Count -eq 0) {
        Write-Warning "No markdown files found in '$docsPath'. Skipping help file generation."
        return
    }

    $helpFile =
        Measure-PlatyPSMarkdown $mdFiles.FullName
        | Where-Object { $_.FileType -match 'CommandHelp' -and $_.Metadata.status -ne 'obsolete' }
        | Import-MarkdownCommandHelp -Path { $_.FilePath }
        | Export-MamlCommandHelp -OutputFolder $outputFolder -Force

    if($helpFile.Count -gt 1) {
        throw "$($helpFile.Count) help files generated. Check the 'external help file:' section in the markdown file headers.
        The file name must match the module name and is case sensitive."
    }
    # $helpFile
}