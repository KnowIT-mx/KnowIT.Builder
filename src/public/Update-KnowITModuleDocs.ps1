function Update-KnowITModuleDocs {

    [CmdletBinding()]
    [Alias('docs')]
    param(
        [string]$ProjectFolder,

        [ValidateNotNullOrEmpty()]
        [Alias('ModulePath')]
        [string]$OutputModulePath
    )

    try {
        Update-CallerPreference $PSCmdlet

        AssertPlatyPSModule
        $moduleData = GetModuleFileData $ProjectFolder
        $moduleName = $moduleData.ModuleName
        Write-KnowITBuild "Update docs for module '$moduleName'" -Color Yellow

        $modulePath = $OutputModulePath ? $OutputModulePath : $moduleData.OutputFolder
        if((Split-Path $modulePath -Leaf) -ne $moduleName -or
           !(Test-Path $modulePath/$moduleName.psd1) -or
           !(Test-ModuleManifest $modulePath/$moduleName.psd1)) {
            throw "Module not found at '$modulePath'. Please build the module first."
        }

        $moduleDocs = $moduleData.DocsFolder
        if(!(Test-Path $moduleDocs -PathType Container)) {
            $null = New-Item -ItemType Directory -Path $moduleDocs -Force
        }

        # PlatyPS documentation should be generated in a separate job to avoid issues if module is already loaded in current session.
        # We make sure the current builded module is used to generate the documentation.
        Start-ThreadJob {
            Write-KnowITBuild 'Loading builded module in a new session'
            $importedModule = Import-Module $using:modulePath -PassThru -Force

            Write-KnowITBuild 'Processing Markdown files'
            $commandsDocs =
                Measure-PlatyPSMarkdown $using:moduleDocs/*.md
                | Where-Object { $_.FileType -match 'CommandHelp' -and $_.Metadata.status -ne 'obsolete' }

            $commandsHelp = [Collections.ArrayList]::new()
            $outputFolder = Split-Path $using:moduleDocs
            $i = 0
            foreach($cmd in $commandsDocs) {
                Write-Progress -Id 1 -Activity "Updating command help:" -Status $cmd.Title -PercentComplete (++$i / $commandsDocs.Count * 100)
                $cmdHelp = Update-CommandHelp -Path $cmd.FilePath
                $null = Export-MarkdownCommandHelp $cmdHelp -OutputFolder $outputFolder -Force
                [void]$commandsHelp.Add($cmdHelp)
                Start-Sleep -Milliseconds 10
            }

            $newCommands =
                $importedModule.ExportedFunctions.Values.
                Where({ $_.Name -notin $commandsDocs.Title })

            if($newCommands) {
                Write-KnowITBuild 'New commands found:' -Color Green
                [array]$newCmdHelp = New-CommandHelp $newCommands
                Export-MarkdownCommandHelp $newCmdHelp -OutputFolder $outputFolder
                | ForEach-Object { Write-KnowITBuild "[docs] $($_.Name)" -Color Green }
                $commandsHelp.AddRange($newCmdHelp)
            }

            Write-KnowITBuild 'Generating module index file'
            $null = New-MarkdownModuleFile -CommandHelp $commandsHelp -OutputFolder $outputFolder -Force

        } | Receive-Job -Wait -AutoRemoveJob
    }
    catch {
        $PSCmdlet.WriteError($_)
    }
}
