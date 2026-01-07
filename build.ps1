param(
    [string]$Version,
    [string]$BuildNumber
)

$ErrorActionPreference = 'Stop'

./run.ps1
Build-KnowITModule @PSBoundParameters