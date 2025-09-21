function BuildManifest ([int]$BuildNumber = -1) {

    $moduleName = $ModuleData.ModuleName
    Write-Build "  Building Module Manifest: '$moduleName.psd1'..."

    $manifest = $ModuleData.Manifest
    $allowedParams = (Get-Command New-ModuleManifest).Parameters.Keys
    $invalidKeys = $manifest.Keys.Where({ $_ -notin $allowedParams -or !$manifest[$_] })
    if($invalidKeys.Count -gt 0) {
        Write-Warning "  Removing invalid or empty keys in Manifest ($($invalidKeys -join ', '))..."
        $invalidKeys.ForEach({ $manifest.Remove($_) })
    }
    # Manifest default values
    $manifest.FunctionsToExport = ''
    $manifest.CmdletsToExport = ''
    $manifest.VariablesToExport = ''
    $manifest.PrivateData ??= @{}

    $version, $prerelease = $ModuleData.Version.Split('-', 2)
    $buildVersion = GetBuildVersion $version $BuildNumber
    $manifest.ModuleVersion = $buildVersion
    if($prerelease) {
        $manifest.PreRelease = $prerelease
        $fullVersion = "$buildVersion-$prerelease"
    }
    else {
        $fullVersion = $buildVersion
    }
    Write-Build "Module final version: [$fullVersion]"
    $manifest.PrivateData.FullVersion = $fullVersion
    $manifest.PrivateData.Builder = 'KnowIT.Builder'

    $manifest.GUID = $ModuleData.ModuleId
    $manifest.Author = $ModuleData.Author
    $manifest.Description = $ModuleData.Description
    $manifest.RootModule = "$moduleName.psm1"

    if($ModuleData.PublicFunctions) {
        $manifest.FunctionsToExport = $ModuleData.PublicFunctions
    }
    if($ModuleData.ExternalModules) {
        $manifest.RequiredModules = $ModuleData.ExternalModules
        $manifest.ExternalModuleDependencies = $ModuleData.ExternalModules
    }
    # $manifest.NestedModules = $NestedModules
    # $manifest.RequiredAssemblies = $Assemblies.ForEach({"bin/$_.dll"})

    $manifest.Path = Join-Path $ModuleData.OutputFolder "$moduleName.psd1"

    Write-Debug 'Module Manifest Parameters:'
    Write-Debug ($manifest | Out-String)
    New-ModuleManifest @manifest
}
