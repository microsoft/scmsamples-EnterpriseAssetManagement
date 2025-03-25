$ErrorActionPreference = "Stop"

$rootDirectory = "$PSScriptRoot\.."
$solutionPath = "$rootDirectory\Solution"
$solutionExportPath = "$SolutionPath\Export"
[xml]$solutionXml = Get-Content "$solutionExportPath\Other\Solution.xml"

$canvasAppComponent = $solutionXml.ImportExportXml.SolutionManifest.RootComponents.RootComponent | Where-Object { $_.type -eq '300' }

$msAppName = $canvasAppComponent.schemaName

$msAppRelativePath = "CanvasApps\$($msAppName)_DocumentUri.msapp"

$appExportLocation = Join-Path $solutionExportPath $msAppRelativePath
$tempAppExportLocation = [System.IO.Path]::GetTempFileName() + '.zip'

# Packing from \AppSource seems to break the app until it is republished.
# Do not re-enable YAML as source of truth while PAC has that bug.
#$appSourceDirectory = Join-Path $rootDirectory "\AppSource"
#.\packages\Microsoft.PowerApps.CLI.1.39.3\tools\pac.exe canvas pack --sources $appSourceDirectory --msapp $appExportLocation

$appSourceDirectory = Join-Path $rootDirectory "CanvasAppSource\*"
Compress-Archive -Path $appSourceDirectory -DestinationPath $tempAppExportLocation -Force

Remove-Item $appExportLocation -Force -ErrorAction SilentlyContinue

Copy-Item $tempAppExportLocation $appExportLocation -Force
