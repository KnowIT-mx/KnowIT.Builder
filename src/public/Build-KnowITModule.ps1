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

        if($PSBoundParameters.ContainsKey('MergePSM')) {
            $moduleData.MergePSM = $MergePSM.IsPresent
        }

        $projectFolder = $moduleData.ProjectFolder
        Write-Build "  Module project folder: '$projectFolder'"
        Push-Location $rPojectFolder
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