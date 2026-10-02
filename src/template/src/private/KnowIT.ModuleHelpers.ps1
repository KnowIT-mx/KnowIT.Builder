function Update-CallerPreference {
    # https://devblogs.microsoft.com/scripting/weekend-scripter-access-powershell-preference-variables/
    param(
        [ValidateNotNull()]
        [PSTypeName('System.Management.Automation.PSScriptCmdlet')]$ScriptCmdlet = (Get-Variable PSCmdlet -Scope 1 -ValueOnly),

        [ValidateSet('ErrorAction', 'WarningAction', 'Verbose', 'Debug', 'InformationAction', 'ProgressAction', 'Confirm', 'WhatIf')]
        [string[]]$Skip
    )

    $preferenceParameters = @{
        ErrorAction       = 'ErrorActionPreference'
        WarningAction     = 'WarningPreference'
        Verbose           = 'VerbosePreference'
        Debug             = 'DebugPreference'
        InformationAction = 'InformationPreference'
        ProgressAction    = 'ProgressPreference'
        Confirm           = 'ConfirmPreference'
        WhatIf            = 'WhatIfPreference'
    }

    $invocation = $ScriptCmdlet.MyInvocation
    $commandDebug = $invocation.BoundParameters.ContainsKey('Debug')

    if($commandDebug) { Write-Debug "Updating [$($invocation.MyCommand)] Preference variables:" }

    foreach($p in $preferenceParameters.Keys) {
        $var = $preferenceParameters[$p]

        if($invocation.BoundParameters.ContainsKey($p)) {
            if($commandDebug) {
                Write-Debug "  $var = '$(Get-Variable $var -ValueOnly)' (from -$p parameter)" 
            }
            continue
        }

        if($p -eq 'ErrorAction') {
            $val = 'Stop'
            $scope = 'Update-CallerPreference'
        }
        elseif($p -in $Skip) {
            $val = Get-Variable -Scope Global -Name $var -ValueOnly
            $scope = 'Global scope'
        }
        else {
            $val = $ScriptCmdlet.GetVariableValue($var)
            $scope = 'Caller scope'
        }
        if($commandDebug) { Write-Debug "  $var = '$val' (from $scope)" }
        Set-Variable -Scope 1 -Name $var -Value $val -WhatIf:$false -Confirm:$false
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