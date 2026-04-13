function BuildPSM ($SourceFiles)
{
    $ErrorActionPreference = 'Stop'

    $moduleName = $script:ModuleData.ModuleName
    $output = $script:ModuleData.OutputFolder
    Write-Build "  Building module file: '$moduleName.psm1'..."
    $null = New-Item $output -ItemType Directory -Force

    $sourceBuilder = [Text.StringBuilder]::new()
    $usings = [Collections.Generic.SortedSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    $requires = [Collections.Generic.SortedSet[string]]::new([StringComparer]::OrdinalIgnoreCase)

    [void]$sourceBuilder.AppendLine("`n#region === Public functions ===")
    foreach($source in $SourceFiles.Public) {
        [void]$sourceBuilder.AppendLine("`n### Source file: '$($source.Name)' ###")
        Get-Content $source | ParseSource $sourceBuilder $usings $requires
    }
    [void]$sourceBuilder.AppendLine("`n#endregion")

    [void]$sourceBuilder.AppendLine("`n#region === Private functions ===")
    foreach($source in $SourceFiles.Private) {
        [void]$sourceBuilder.AppendLine("`n### Source file: '$($source.Name)' ###")
        Get-Content $source | ParseSource $sourceBuilder $usings $requires
    }
    [void]$sourceBuilder.AppendLine("`n#endregion")

    if($ModuleData.MergePSM) {
        $currentPSM = FindCurrentPSM
        Write-Build "  Merging '$currentPSM' file..."
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
