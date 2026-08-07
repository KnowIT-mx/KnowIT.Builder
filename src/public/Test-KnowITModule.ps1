function Test-KnowITModule {

    [CmdletBinding()]
    [Alias('test')]
    param(
        [string]$ProjectFolder,

        [Alias('Configuration')]
        [hashtable]$PesterConfiguration = @{},

        [Alias('ImportModule','ModulePath')]
        [string]$OutputModulePath,

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
        $moduleData = GetModuleFileData $ProjectFolder
        $moduleName = $moduleData.ModuleName
        Write-KnowITBuild "Running tests for module '$moduleName'"

        $PesterConfiguration.Run ??= @{}
        $PesterConfiguration.Run.Path ??= $moduleData.ProjectFolder
        if($OutputModulePath) {
            $importModule = Convert-Path $OutputModulePath
        }

        $script = {
            param($PesterConfiguration, $ImportModule, $DebugPreference)

            $VerbosePreference = 'SilentlyContinue'
            $DebugPreference = $DebugPreference

            Write-Debug ($PSVersionTable | Out-String)
            Import-Module Pester -DisableNameChecking

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
                ArgumentList = @($PesterConfiguration, $importModule, $DebugPreference)
            }
            if($InitializationScript) {
                $params.InitializationScript = $InitializationScript
            }
            if($JobVersion) {
                Write-Build "[TEST] Running tests in a PowerShell $JobVersion job ..." Yellow
                $params.PSVersion = $JobVersion
            }
            else {
                Write-Build '[TEST] Running tests in a PowerShell job ...' Yellow
            }
            Start-Job @params | Receive-Job -Wait -AutoRemoveJob
        }
        else {
            Write-Build '[TEST] Running tests in the current PowerShell session ...' Yellow
            Invoke-Command $script -ArgumentList $PesterConfiguration, $importModule, $DebugPreference
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
