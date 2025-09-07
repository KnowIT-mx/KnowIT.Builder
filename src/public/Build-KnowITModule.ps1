function Build-KnowITModule {

    [CmdletBinding(DefaultParameterSetName = 'BuildNumber')]
    [Alias('build')]
    param(
        [Parameter(ParameterSetName = 'Version')]
        [ValidateScript({ ValidateVersion $_ })]
        [string]$Version,

        [Parameter(ParameterSetName = 'BuildNumber')]
        [int]$BuildNumber = -1,

        [switch]$MergePSM
    )

    $ErrorActionPreference = 'Stop'

    try {
        Write-Build 'Procesing module data file...'
        $script:ModuleData = Get-KnowITModuleInfo

        if($Version) {
            $ModuleData.Version = $Version
        }
        Write-Build "Module output location: '$($ModuleData.OutputFolder)'"
        BuildPSM -Merge:$MergePSM
        BuildManifest $BuildNumber
    }
    catch {
        Write-Error $_
    }
}