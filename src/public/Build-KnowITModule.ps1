function Build-KnowITModule {

    [CmdletBinding(DefaultParameterSetName = 'BuildNumber')]
    [Alias('build')]
    param(
        [Parameter(Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string]$Path = '.',

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
        $script:ModuleData = GetModuleFileData $Path

        if($Version) {
            $ModuleData.Version = $Version
        }
        else {
            $null = ValidateVersion $ModuleData.Version
        }
        Write-Build "Module output location: '$($ModuleData.OutputFolder)'"
        BuildPSM -Merge:$MergePSM
        BuildManifest $BuildNumber
    }
    catch {
        Write-Error $_
    }
}