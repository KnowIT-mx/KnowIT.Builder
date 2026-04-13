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
        Write-Build 'Procesing module data file...'
        $script:ModuleData = GetModuleFileData $Path

        if($Version) {
            $ModuleData.Version = $Version
        }
        else {
            $null = ValidateVersion $ModuleData.Version
        }
        if($PSBoundParameters.ContainsKey('MergePSM')) {
            $script:ModuleData.MergePSM = $MergePSM.IsPresent
        }

        Push-Location $ModuleData.ProjectFolder
        if(Test-Path src -PathType Container) {
            Set-Location src
        }
        $output = $ModuleData.OutputFolder
        Write-Build "Module output location: '$output'"
        if(Test-Path $output) {
            $null = Remove-Item $output -Recurse -Force
        }

        $sourceFiles = ProcessSourceFolders
        BuildPSM $sourceFiles
        $script:ModuleData.PublicFunctions = $sourceFiles.PublicFunctions
        $script:ModuleData.Aliases = $sourceFiles.Aliases

        if($extra = $ModuleData.ExtraContent) {
            Write-Build "  Copying extra content: ($($extra -join ', '))..."
            Copy-Item $extra -Destination $output -Recurse -Force
        }

        BuildManifest $BuildNumber
    }
    catch {
        $PSCmdlet.WriteError($_)
    }
    finally {
        Pop-Location
    }
}