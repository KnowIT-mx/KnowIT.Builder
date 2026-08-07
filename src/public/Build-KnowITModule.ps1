function Build-KnowITModule {

    [CmdletBinding(DefaultParameterSetName = 'BuildNumber')]
    [Alias('build')]
    param(
        [Parameter(Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [Alias('Path')]
        [string]$ProjectFolder,

        [Parameter(ParameterSetName = 'Version')]
        [ValidateScript({ ValidateVersion $_ })]
        [string]$Version,

        [Parameter(ParameterSetName = 'BuildNumber')]
        [int]$BuildNumber = -1,

        [Alias('OutputFolder')]
        [string]$OutputPath,

        [string[]]$ExtraContent,

        [hashtable]$Manifest
    )

    try {
        Update-CallerPreference $PSCmdlet

        Write-Build 'Loading module data file and processing parameters...'
        $moduleData = GetModuleFileData $ProjectFolder

        switch ($PSCmdlet.ParameterSetName) {
            'Version' {
                $moduleData.Version = $Version
                $moduleData.BuildNumber = -1
            }
            'BuildNumber' {
                $null = ValidateVersion $moduleData.Version
                $moduleData.BuildNumber = $BuildNumber
            }
        }

        switch ($PSBoundParameters.Keys) {
            'OutputPath' {
                $moduleData.OutputFolder = [IO.Path]::GetFullPath([IO.Path]::Combine($OutputPath, $moduleData.ModuleName), $PWD.Path)
            }
            'Manifest' {
                foreach($key in $Manifest.Keys) {
                    if($key -eq 'PrivateData') {
                        $moduleData.Manifest.PrivateData ??= @{}
                        foreach($subkey in $Manifest.PrivateData.Keys) {
                            $moduleData.Manifest.PrivateData[$subkey] = $Manifest.PrivateData[$subkey]
                        }
                    }
                    else {
                        $moduleData.Manifest[$key] = $Manifest[$key]
                    }
                }
            }
            'ExtraContent' {
                $moduleData.ExtraContent = $ExtraContent
            }
        }

        $projectFolder = $moduleData.ProjectFolder
        Write-Build "  Module project folder: '$projectFolder'"
        Push-Location $projectFolder
        if(Test-Path src -PathType Container) {
            Set-Location src
        }
        Write-Build "  Module build output path: '$($moduleData.OutputFolder)'"
        Write-Build

        ProcessSourceFolders $moduleData
        BuildPSM $moduleData

        if($extra = $moduleData.ExtraContent) {
            Write-Build "Copying extra content: ($($extra -join ', '))..."
            Copy-Item $extra -Destination $moduleData.OutputFolder -Recurse -Force
        }

        Write-Build
        BuildManifest $moduleData
    }
    catch {
        $PSCmdlet.WriteError($_)
    }
    finally {
        Pop-Location
    }
}