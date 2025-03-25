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

$appSourceDirectory = Join-Path $rootDirectory "CanvasAppSource\*"
Compress-Archive -Path $appSourceDirectory -DestinationPath $tempAppExportLocation -Force

Remove-Item $appExportLocation -Force -ErrorAction SilentlyContinue

Copy-Item $tempAppExportLocation $appExportLocation -Force

$relativeMsAppPathFromRoot = "Solution\Export\$msAppRelativePath"
Write-Output "Sucessfully packed canvas msapp in $relativeMsAppPathFromRoot"