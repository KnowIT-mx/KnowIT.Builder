
function Get-KnowITModuleInfo {

    [CmdletBinding()]
    [Alias('moduleinfo')]
    param(
        [string]$Path
    )

    $ErrorActionPreference = 'Stop'

    try {
        $data = GetModuleFileData $Path
        [PSCustomObject]$data
        $null = ValidateVersion $data.Version
    }
    catch {
        $PSCmdlet.WriteError($_)
    }
}
