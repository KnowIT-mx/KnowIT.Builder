function ValidateVersion ([string]$Version)
{
    $regex = '^(0|[1-9]\d*)(\.(0|[1-9]\d*))?\.(?:x|X|0|[1-9]\d*)(?:-[A-Za-z0-9.]+)?$'

    if($Version -notmatch $regex) {
        throw 'Invalid version format. Please use ''Major[.Minor].Build'' and an optional prerelease. Last segment can be ''x'' to indicate an incremental build number.'
    }
    return $true
}

function GetBuildVersion ([string]$Version, [int]$BuildNumber = -1)
{
    # Fixed version whithout a build number in parameters return as.is
    if($BuildNumber -eq (-1) -and -not $Version.Contains('x')) {
        return [version]$Version
    }

    Write-Build '  Applying Build Number:'
    if($BuildNumber -eq -1) {
        $BuildNumber = [Math]::Floor([DateTimeOffset]::Now.ToUnixTimeSeconds() / 60)
        Write-Build "  |$BuildNumber| (UnixMinutes)"
    }
    else {
        Write-Build "  |$BuildNumber| (Parameter)"
    }

    $segments = $Version.Replace('.x', '.0').Split('.')
    [version]::new($segments[0], $segments[1], $BuildNumber)
}
