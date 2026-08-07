function Test-KnowITModule {

    [CmdletBinding()]
    [Alias('test')]
    param(
        [Alias('Configuration')]
        [hashtable]$PesterConfiguration = @{},

        [Alias('ModulePath')]
        [string]$ImportModule, 
        
        [switch]$NoThrow,

        [Parameter(ParameterSetName = 'Job')]
        [switch]$AsJob, 

        [Parameter(ParameterSetName = 'Job')]
        [ValidateSet('5.1')]
        [version]$JobVersion,

        [Parameter(ParameterSetName = 'Job')]
        [scriptblock]$InitializationScript
    )

    try {
        Update-CallerPreference $PSCmdlet

        AssertPesterModule
        $PesterConfiguration.Run ??= @{}
        $PesterConfiguration.Run.Path ??= $PWD.Path
        if($ImportModule) {
            $ImportModule = Convert-Path $ImportModule
        }

        $script = {
            param($PesterConfiguration, $ImportModule, $DebugPreference)
            
            $VerbosePreference = 'SilentlyContinue'
            $DebugPreference = $DebugPreference
            Write-Debug ($PSVersionTable | Out-String)
            
            Import-Module Pester
           # Pester v5 does not support ArrayLists in the configuration Hashtable
            foreach($section in $PesterConfiguration.Values) {
                foreach($key in @($section.Keys)) {
                    if($section[$key] -is [Collections.ArrayList]) {
                        $section[$key] = $section[$key].ToArray()
                    }
                }
            }   
            Write-Debug "Pester configuration: $($PesterConfiguration | Out-String)"
            $pesterConfig = New-PesterConfiguration -Hashtable $PesterConfiguration
            $pesterConfig.Run.PassThru = $true

            if($ImportModule) {
                Import-Module $ImportModule -Force
            }
            Invoke-Pester -Configuration $pesterConfig
        }

        $testOutput = if($AsJob) {
            $params = @{
                ScriptBlock = $script
                ArgumentList = @($PesterConfiguration, $ImportModule, $DebugPreference)
            }
            if($InitializationScript) {
                $params.InitializationScript = $InitializationScript
            }
            if($JobVersion) {
                Write-Build "[TEST] Running tests in a PowerShell $JobVersion job..." Magenta
                $params.PSVersion = $JobVersion
            }
            else {
                Write-Build '[TEST] Running tests in a PowerShell job...' Magenta
            }
            Start-Job @params | Receive-Job -Wait -AutoRemoveJob
        }
        else {
            Write-Build '[TEST] Running tests in the current PowerShell session...' Magenta
            Invoke-Command $script -ArgumentList $PesterConfiguration, $ImportModule, $DebugPreference
        }

        if(!$testOutput) {
            throw 'There was a problem running the tests.'
        }
        if($NoThrow) {
            return $testOutput
        }   
        if($testOutput.FailedCount -gt 0) {
            throw "$($testOutput.FailedCount) test(s) failed!"
        }
    }
    catch {
        $PSCmdlet.WriteError($_)
    }
}
