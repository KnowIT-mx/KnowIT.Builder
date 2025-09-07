
function Get-KnowITModuleInfo {

    [Alias('moduleinfo')]
    param(
        [string]$Path = '.'
    )

    try {
        $rootFolder = Convert-Path $Path

        $data = GetModuleFileData $rootFolder
        [PSCustomObject]$data
        $null = ValidateVersion $data.Version
    }
    catch {
        Write-Error $_
    }
}
