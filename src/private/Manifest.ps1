function BuildManifest ([int]$BuildNumber = -1) {

    $moduleName = $ModuleData.ModuleName
    Write-Build "  Building Module Manifest: '$moduleName.psd1'..."

    $manifest = $ModuleData.Manifest
    $allowedParams = (Get-Command New-ModuleManifest).Parameters.Keys
    $invalidKeys = $manifest.Keys.Where({ $_ -notin $allowedParams })
    if($invalidKeys.Count -gt 0) {
        Write-Warning "Found invalid keys in Manifest: ($($invalidKeys -join ', '))"
        $invalidKeys.ForEach({ $manifest.Remove($_) })
    }
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
    Write-Build "Module final version: v$fullVersion"
    $manifest.PrivateData.FullVersion = $fullVersion

    $manifest.RootModule = "$moduleName.psm1"
    $manifest.Description = $ModuleData.Description

    $manifest.FunctionsToExport = $ModuleData.PublicFunctions
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

function GetBuildVersion ([string]$Version, [int]$BuildNumber = -1)
{
    if(!$Version.Contains('x')) {
        return [version]$Version
    }

    Write-Build '  Applying Build Version...'
    if($Version -notmatch '^(?:\d+\.)*\d+(\.x)?$') {
        throw "Only the last segment in version is allowed to contain '.x' for build number."
    }

    if($BuildNumber -eq -1) {
        $BuildNumber = [Math]::Floor([DateTimeOffset]::Now.ToUnixTimeSeconds() / 60)
        Write-Build "  [-] Build Number: '$BuildNumber' (UnixMinutes)"
    }
    else {
        Write-Build "  [-] Build Number: '$BuildNumber' (Parameters)"
    }
    $Version = $Version.TrimEnd('x') + $BuildNumber
    [version]$Version
}

