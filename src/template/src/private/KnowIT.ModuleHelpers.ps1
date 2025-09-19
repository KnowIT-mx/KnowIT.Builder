function Update-CallerPreference {
    # https://devblogs.microsoft.com/scripting/weekend-scripter-access-powershell-preference-variables/
    param(
        [ValidateNotNull()]
        [PSTypeName('System.Management.Automation.PSScriptCmdlet')]$ScriptCmdlet = (Get-Variable PSCmdlet -Scope 1 -ValueOnly),

        [ValidateSet('ErrorAction', 'Warning', 'Verbose', 'Debug', 'Information', 'Progress', 'Confirm', 'WhatIf')]
        [string[]]$Skip
    )

    $commonParameters = 'ErrorAction', 'Warning', 'Verbose', 'Debug', 'Information', 'Progress', 'Confirm', 'WhatIf'
    $currentDebugPreference = $DebugPreference

    Write-Debug "Updating [$($ScriptCmdlet.MyInvocation.MyCommand)] Preference variables:"
    foreach($p in $commonParameters) {
        if($ScriptCmdlet.MyInvocation.BoundParameters.ContainsKey($p)) {
            continue
        }
        $var = "${p}Preference"

        if($p -eq 'ErrorAction') {
            $val = 'Stop'
            $scope = 'Forced'
        }
        elseif($p -in $Skip) {
            $val = Get-Variable -Scope Global -Name $var -ValueOnly
            $scope = 'Global'
        }
        else {
            $val = $ScriptCmdlet.GetVariableValue($var)
            $scope = 'Caller'
        }
        Write-Debug "  (From $scope scope) $var = $val " -Debug:$currentDebugPreference
        Set-Variable -Scope 1 -Name $var -Value $val
    }
}

function Map-Object {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '', Justification = 'Internal functions')]
    param([scriptblock]$ScriptBlock)

begin {
    $code = "& { process { $ScriptBlock } }"
    $pipeline = [scriptblock]::Create($code).GetSteppablePipeline()
    $pipeline.Begin($true)
}
process {
    $pipeline.Process($_)
}
end {
    $pipeline.End()
}
}