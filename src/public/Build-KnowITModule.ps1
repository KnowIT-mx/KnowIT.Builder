function Build-KnowITModule {

    [CmdletBinding(DefaultParameterSetName = 'BuildNumber')]
    [Alias('build')]
    param(
        [Parameter(ParameterSetName = 'Version')]
        [string]$Version,

        [Parameter(ParameterSetName = 'BuildNumber')]
        [int]$BuildNumber = -1,

        [switch]$MergePSM
    )

    $ErrorActionPreference = 'Stop'

    try {
        $script:ModuleData = Get-KnowITModuleInfo

        #TODO: Quiboles con el GUID
        BuildPSM -Merge:$MergePSM
        BuildManifest $BuildNumber
    }
    catch {
        Write-Error $_
    }
}