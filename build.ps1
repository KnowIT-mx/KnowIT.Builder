param(
    [string]$Version,
    [string]$BuildNumber,
    [string]$OutputPath
)

$ErrorActionPreference = 'Stop'

./run.ps1
Build-KnowITModule @PSBoundParameters