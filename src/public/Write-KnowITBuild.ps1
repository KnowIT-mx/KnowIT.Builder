function Write-KnowITBuild {

    [CmdletBinding()]
    [Alias('Out-Build','echo')]
    param(
        [Parameter(Position = 0, ParameterSetName = 'Message',
                ValueFromPipeline)]
        [string]$Message,

        [Parameter(Position = 1, ParameterSetName = 'Message')]
        [ConsoleColor]$Color = 'Blue',

        [Parameter(Mandatory, ParameterSetName = 'BlankLine')]
        [Alias('LineBreak')]
        [switch]$BlankLine
    )

begin {
    Update-CallerPreference $PSCmdlet
    if($BlankLine) { Write-Host }
}

process {
    try {
        if($PSCmdlet.ParameterSetName -eq 'BlankLine') {
            return
        }
        Write-Host "[BUILD] $Message" -ForegroundColor $Color
    }
    catch {
        $PSCmdlet.WriteError($_)
    }
}

}