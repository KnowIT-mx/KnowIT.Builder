function BuildManifest {
    $moduleData = Get-ModuleInfo
    $moduleName = $moduleData.ModuleName
    Write-Build Magenta "  Actualizando archivo Manifest: '$moduleName.psd1'..."

    $manifest = $moduleData.Manifest
    $allowedParams = (Get-Command New-ModuleManifest).Parameters.Keys
    $invalidKeys = $manifest.Keys.Where({ $_ -notin $allowedParams })
    if($invalidKeys.Count -gt 0) {
        Write-Warning "Found invalid keys in Manifest: ($($invalidKeys -join ', '))"
        $invalidKeys.ForEach({ $manifest.Remove($_) })
    }
    $version, $prerelease = $moduleData.Version.Split('-', 2)
    $manifest.ModuleVersion = $version
    if($prerelease) { $manifest.PreRelease = $prerelease }
    $manifest.PrivateData ??= @{}
    $manifest.PrivateData.FullVersion = $moduleData.Version
    $manifest.RootModule = "$moduleName.psm1"
    $manifest.Description = $moduleData.Description
    $manifest.FunctionsToExport = GetPublicFunctions
    $manifest.Path = Join-Path $moduleData.OutputFolder "$moduleName.psd1"
    # $manifest.NestedModules = $NestedModules
    # $manifest.RequiredAssemblies = $Assemblies.ForEach({"bin/$_.dll"})

    $manifest
    New-ModuleManifest @manifest
    # Set-Content "$OutputModule/$Configuration.version" ($script:Version, $CommitId)
}

function GetPublicFunctions
{
    $publicFolder = $moduleData.PSSourceFiles.Where({ (Split-Path $_ -Leaf) -eq 'Public' })
    (Get-ChildItem $publicFolder -Include '*.ps1' -Recurse).BaseName
}
