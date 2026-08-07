
function Get-KnowITModuleInfo {

    [CmdletBinding()]
    [Alias('moduleinfo')]
    param(
        [Alias('Path')]
        [string]$ProjectFolder
    )

    try {
        Update-CallerPreference $PSCmdlet

        $data = GetModuleFileData $ProjectFolder
        [PSCustomObject]$data
        $null = ValidateVersion $data.Version
    }
    catch {
        $PSCmdlet.WriteError($_)
    }
}
