function New-KnowITModuleFunction {

    [CmdletBinding()]
    [Alias('nfunc')]
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    $ErrorActionPreference = 'Stop'

    try {
        $moduleData = GetModuleFileData (FindProjectRoot)
        $functionFile = Join-Path $moduleData.ProjectFolder 'src/public' "$Name.ps1"
        if(Test-Path $functionFile) {
            throw "Function file '$Name.ps1' already exists!"
        }

        $templateFile = Join-Path $moduleData.ProjectFolder 'src/public/_function.template'
        if(!(Test-Path $templateFile)) {
            $templateFile = Join-Path $PSModuleRoot 'template/src/public/_function.template'
        }

        $template = Get-Content $templateFile -Raw
        $template.Replace('{{FunctionName}}', $Name) |
            Set-Content $functionFile -Encoding utf8BOM

        Write-Build "New public function file created: $functionFile"

        if($env:TERM_PROGRAM -eq 'vscode') {
            if($env:TERM_PROGRAM_VERSION -like '*-insider') {
                code-insiders -r $functionFile
            }
            else {
                code -r $functionFile
            }
        }
    }
    catch {
        $PSCmdlet.WriteError($_)
    }
}
