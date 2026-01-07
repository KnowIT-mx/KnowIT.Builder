function New-KnowITModuleFunction {

    [CmdletBinding()]
    [Alias('nfunc')]
    param(
        [Parameter(Mandatory)]
        [string]$Name
    )

    $ErrorActionPreference = 'Stop'

    try {
        $moduleData = GetModuleFileData
        $srcFolder = Join-Path $moduleData.ProjectFolder 'src'
        if(!(Test-Path $srcFolder -PathType Container)) {
            $srcFolder = $moduleData.ProjectFolder
        }
        $functionFile = Join-Path $srcFolder 'public' "$Name.ps1"
        if(Test-Path $functionFile) {
            throw "Function file '$Name.ps1' already exists!"
        }

        $templateFile = Join-Path $srcFolder 'public/_function.template'
        if(!(Test-Path $templateFile)) {
            Write-Debug 'No existing template in current module, using default template.'
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
