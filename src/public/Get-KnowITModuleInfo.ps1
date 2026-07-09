
function Get-KnowITModuleInfo {

    [CmdletBinding()]
    [Alias('moduleinfo')]
    param(
        [string]$Path
    )

    try {
        Update-CallerPreference $PSCmdlet

        $data = GetModuleFileData $Path
        [PSCustomObject]$data
        $null = ValidateVersion $data.Version
    }
    catch {
        $PSCmdlet.WriteError($_)
    }
}
