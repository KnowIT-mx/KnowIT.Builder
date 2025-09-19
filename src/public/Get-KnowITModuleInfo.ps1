
function Get-KnowITModuleInfo {

    [CmdletBinding()]
    [Alias('moduleinfo')]
    param(
        [string]$Path = '.'
    )

    $ErrorActionPreference = 'Stop'

    try {
        $rootFolder = Convert-Path $Path

        $data = GetModuleFileData $rootFolder
        [PSCustomObject]$data
        $null = ValidateVersion $data.Version
    }
    catch {
        $PSCmdlet.WriteError($_)
    }
}
