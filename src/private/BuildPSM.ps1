function BuildPSM
{
    $ErrorActionPreference = 'Stop'

    try {
        $moduleName = $ModuleData.ModuleName
        Write-Build "  Building module file: '$moduleName.psm1'..."
        Push-Location (Join-Path $ModuleData.ProjectFolder 'src')

        $output = $ModuleData.OutputFolder
        $null = New-Item $output -ItemType Directory -Force

        $sourceBuilder = [Text.StringBuilder]::new()
        $usings = [Collections.Generic.SortedSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
        $requires = [Collections.Generic.SortedSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
        $sourceFiles = ProcessSourceFolders

        [void]$sourceBuilder.AppendLine("`n#region === Source functions ===")
        foreach($source in $sourceFiles) {
            [void]$sourceBuilder.AppendLine("`n### Source file: '$($source.Name)' ###")
            Get-Content $source | ParseSource $sourceBuilder $usings $requires
        }
        [void]$sourceBuilder.AppendLine("`n#endregion")

        $currentPSM = "$moduleName.psm1"
        if($ModuleData.MergePSM -and (Test-Path $currentPSM)) {
            Write-Build '  Merging current PSM file...'
            [void]$sourceBuilder.AppendLine("`n#region === Source .psm1 file ===")
            Get-Content $currentPSM | ParseSource $sourceBuilder $usings $requires -SkipRegion '=== .Source files ==='
            [void]$sourceBuilder.AppendLine("`n#endregion")
        }

        # using directives must be at the top of the file
        if($usings.Count -gt 0) {
            [void]$sourceBuilder.Insert(0, "$($usings -join "`n")`n")
        }

        if($requires.Count -gt 0) {
            Write-Build '  Procesing Required Modules...'
            $ModuleData.ExternalModules.ForEach({ [void]$requires.Add($_) })
            $ModuleData.ExternalModules = $requires
        }

        $sourceCode = $sourceBuilder.ToString()

        #TODO:External help
        if($script:HelpFile) {
            $helpPattern = "(?ms)(\<#.*?\.SYNOPSIS.*?#>)"
            $externalHelp = "# .ExternalHelp $ModuleName-help.xml`n"
            $sourceCode = $sourceCode -replace $helpPattern, $externalHelp
        }

        $sourceCode | Set-Content "$output/$moduleName.psm1" -Encoding utf8BOM

        if($extra = $ModuleData.ExtraContent) {
            Write-Build "  Copying extra content: ($($extra -join ', '))..."
            Copy-Item $extra -Destination $output -Recurse -Force
        }
    }
    finally {
        Pop-Location
    }
}

function ProcessSourceFolders
{
    Write-Build "  Processing source files in folders: ($($ModuleData.PSSourceFiles -join ', '))..."
    foreach($path in $ModuleData.PSSourceFiles) {
        $files = Get-ChildItem -Filter $path -Directory |
            Get-ChildItem -Filter '*.ps1' -Recurse
        if($path -eq 'public') {
            $ModuleData.PublicFunctions = $files.BaseName
        }
        $files
    }
}

filter ParseSource ($Builder, $Usings, $Requires, $SkipRegion)
{
begin {
    $skipPattern = [string]::IsNullOrWhiteSpace($SkipRegion) ?
        '^#region\ SKIP_BUILD' :
        "^#region\ (SKIP_BUILD|$([regex]::Escape($SkipRegion)))"
    $skipping = $false
    $lineNumber = 0
}

process {
    $lineNumber++
    switch -Regex ($_) {
        '^\s*using' {
            [void]$Usings.Add($_.Trim())
            break
        }
        '^\s*#requires -Modules\s*(.*)' {
            $Matches[1].Split(',').
                ForEach({ [void]$Requires.Add($_.Trim()) })
            break
        }
        $skipPattern {
            if($skipping) { throw "Nested skipped regions are not supported. Line: $lineNumber" }
            $skipping = $true
            break
        }
        '^#endregion' {
            if(!$skipping) {
                [void]$SourceBuilder.AppendLine($_)
            }
            else { $skipping = $false }
        }
        default {
            if(!$skipping) { [void]$SourceBuilder.AppendLine($_) }
        }
    }
}
}
