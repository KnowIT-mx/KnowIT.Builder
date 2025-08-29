function BuildPSM ([switch]$Merge)
{
    $ErrorActionPreference = 'Stop'

    $moduleName = $ModuleData.ModuleName
    $output = $ModuleData.OutputFolder

    Write-Build "Module output location: [$output]"
    $null = New-Item $output -ItemType Directory -Force

    try {
        Write-Build "  Building module file: '$moduleName.psm1'..."
        Push-Location (Join-Path $ModuleData.ProjectFolder 'src')

        $sourceBuilder = [Text.StringBuilder]::new()
        $usings = [Collections.Generic.SortedSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
        $requires = [Collections.Generic.SortedSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
        $sourceFiles = Get-ChildItem $ModuleData.PSSourceFiles -Include '*.ps1' -Recurse

        [void]$sourceBuilder.AppendLine("`n#region === Source functions ===")
        foreach($source in $sourceFiles) {
            [void]$sourceBuilder.AppendLine("`n### Source file: '$($source.Name)' ###")
            Get-Content $source | ParseSource $sourceBuilder $usings $requires
        }
        [void]$sourceBuilder.AppendLine("`n#endregion")

        $currentPSM = "$moduleName.psm1"
        if($Merge -and (Test-Path $currentPSM)) {
            Write-Build '  Merging current PSM file...'
            [void]$sourceBuilder.AppendLine("`n#region === Source .psm1 file ===")
            Get-Content $currentPSM | ParseSource $sourceBuilder $usings $requires -SkipRegion '=== .Source files ==='
            [void]$sourceBuilder.AppendLine("`n#endregion")
        }

        # Header for PSM file (using directives must be at the top followed by #requires)
        if($requires.Count -gt 0) {
            [void]$sourceBuilder.Insert(0, "#requires -Modules $($requires -join ', ')`n")
            Write-Build '  Writing ''requires.txt'' file...'
            $requires | Set-Content "$output/requires.txt" -Encoding utf8BOM
        }
        if($usings.Count -gt 0) {
            [void]$sourceBuilder.Insert(0, "$($usings -join "`n")`n")
        }

        $sourceCode = $sourceBuilder.ToString()

        #TODO:External help
        if($script:HelpFile) {
            $helpPattern = "(?ms)(\<#.*?\.SYNOPSIS.*?#>)"
            $externalHelp = "# .ExternalHelp $ModuleName-help.xml`n"
            $sourceCode = $sourceCode -replace $helpPattern, $externalHelp
        }

        $sourceCode | Set-Content "$output/$moduleName.psm1" -Encoding utf8BOM

        if($additional = $ModuleData.AdditionalFiles) {
            Write-Build "  Copying additional files '$additional'..."
            Copy-Item $additional -Destination $output -Recurse -Force
        }
    }
    finally {
        Pop-Location
    }
}

filter ParseSource {
    param($Builder, $Usings, $Requires, $SkipRegion)

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
