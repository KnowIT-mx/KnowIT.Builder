function Build-KnowITModule {

    [CmdletBinding(DefaultParameterSetName = 'BuildNumber')]
    [Alias('build')]
    param(
        [Parameter(Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string]$Path,

        [Parameter(ParameterSetName = 'Version')]
        [ValidateScript({ ValidateVersion $_ })]
        [string]$Version,

        [Parameter(ParameterSetName = 'BuildNumber')]
        [int]$BuildNumber = -1,

        [string]$OutputFolder,

        [string[]]$ExtraContent,

        [hashtable]$Manifest,

        [switch]$MergePSM
    )

    $ErrorActionPreference = 'Stop'

    try {
        Write-Build 'Loading module data file and processing parameters...'
        $moduleData = GetModuleFileData $Path

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
            'OutputFolder' {    
                $moduleData.OutputFolder = [IO.Path]::GetFullPath([IO.Path]::Combine($OutputFolder, $moduleData.ModuleName), $PWD.Path)
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
            'MergePSM' {
                $moduleData.MergePSM = $MergePSM.IsPresent
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