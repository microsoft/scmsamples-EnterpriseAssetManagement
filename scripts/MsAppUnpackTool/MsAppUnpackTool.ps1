param (
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path $_ })]
    [string] $MsAppPath
)

. "$PSScriptRoot/../utils/FileUtils.ps1"
. "$PSScriptRoot/../utils/PowerAppsUtils.ps1"

$RepoRoot = "$PSScriptRoot/../.."
$sourcePath = "$RepoRoot/CanvasAppSource"

Remove-Directory -directoryPath $sourcePath
$MsAppPath = Prepare-MsAppPath -msAppPath $MsAppPath
Expand-MsAppArchive -msAppPath $MsAppPath -destinationPath $sourcePath

& "$PSScriptRoot/Remove-SecretUrisFromAppSource.ps1"
