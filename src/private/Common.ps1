
function AssertPesterModule {
    $pester = Get-Module -Name Pester -ListAvailable -Verbose:$false
    | Sort-Object -Property Version -Descending
    | Select-Object -First 1
    
    if(!$pester -or $pester.Version.Major -lt 5) {
        throw "Pester module v5 or later is not installed. Please install it from the PowerShell Gallery. Run the following command:`n
        'Install-PSResource -Name Pester -Version '[5.0.0,)' -Repository PSGallery'"
    }
}