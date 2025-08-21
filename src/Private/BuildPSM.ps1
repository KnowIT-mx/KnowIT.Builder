function BuildPSM ([switch]$Clean)
{
    $ErrorActionPreference = 'Stop'

    $moduleData = Get-ModuleInfo
    $moduleName = $moduleData.ModuleName
    $output = $moduleData.OutputFolder

    Write-Build Blue "Module output location: [$output]"
    $null = New-Item $output -ItemType Directory -Force

    $usings = [Collections.Generic.SortedSet[string]]::new([StringComparer]::InvariantCultureIgnoreCase)
    $requires = [Collections.Generic.SortedSet[string]]::new([StringComparer]::InvariantCultureIgnoreCase)
    $sourceBuilder = [Text.StringBuilder]::new()

    Write-Build Magenta "  Building module file: '$moduleName.psm1'..."
    $sourceFiles = Get-ChildItem $moduleData.PSSourceFiles -Include '*.ps1' -Recurse
    foreach($source in $sourceFiles) {
        [void]$sourceBuilder.AppendLine("`n# === Source file: '$($source.Name)' ===")
        Get-Content $source | & { process {
            switch -Regex ($_) {
                '^\s*using' {
                    [void]$usings.Add($_.Trim())
                    break
                }
                '^\s*#requires -Modules\s*(.*)' {
                    $Matches[1].Split(',').
                    ForEach({ [void]$requires.Add($_.Trim()) })
                    break
                }
                default { [void]$sourceBuilder.AppendLine($_) }
            }
        } }
    }
    if($requires.Count -gt 0) {
        [void]$sourceBuilder.Insert(0, "#requires -Modules $($requires -join ', ')`n")
    }

    # Surrounding region for source files
    [void]$sourceBuilder.Insert(0, "`n#region === Source functions === `n")
    [void]$sourceBuilder.AppendLine('#endregion')

    # Usings sections must be at the top of the file
    [void]$sourceBuilder.Insert(0, "$($usings -join "`n")`n")

    $sourceCode = $sourceBuilder.ToString()

    $currentPSM = Join-Path $moduleData.ProjectFolder "src/$moduleName.psm1"
    if(!$Clean -and (Test-Path $currentPSM)) {
        Write-Build Magenta '  Merging current PSM file...'
        $sourceCode = MergePSM $currentPSM $sourceCode $usings
    }

    if($script:HelpFile) {
        $helpPattern = "(?ms)(\<#.*?\.SYNOPSIS.*?#>)"
        $externalHelp = "# .ExternalHelp $ModuleName-help.xml`n"
        $sourceCode = $sourceCode -replace $helpPattern, $externalHelp
    }

    $sourceCode | Set-Content "$output/$moduleName.psm1" -Encoding utf8BOM
    $requires | Set-Content "$output/requires.txt" -Encoding utf8BOM

    if($additional = $moduleData.AdditionalFiles) {
        Write-Build Magenta "  Copying additional files '$additional'..."
        Copy-Item -Path 'src/*' -Include $additional -Destination $output -Recurse -Force
    }
}

function MergePSM ([string]$FilePath, $source, $usings)
{
    # Using directives must be at the top of the file
    $usingSection = $true

    # Merge the existing .psm1 file with the newly generated source code
    Get-Content $FilePath | & { process {
        if($_ -match '^using') {
            if(!$usingSection) {
                Write-Warning 'Using directives must be at the top of the file.'
                return
            }
            return $usings.Contains($_) ? $null : $_
        }
        # End using section and insert source code just before the first non-empty line
        if($usingSection -and -not [string]::IsNullOrWhiteSpace($_)) {
            $usingSection = $false
            $source
        }

        # Skip this region in the original .psm1 file
        if($_ -match '^#region === .Source files ===') {
            $sourceSection = $true
            return $null
        }
        if($sourceSection -and $_ -match "^#endregion") {
            $sourceSection = $false
            return $null
        }

        if(!$sourceSection -and !$usingSection) {
            $_
        }
    } }
}