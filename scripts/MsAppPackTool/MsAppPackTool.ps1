. "$PSScriptRoot/../utils/FileUtils.ps1"
. "$PSScriptRoot/../utils/PowerAppsUtils.ps1"

$ErrorActionPreference = "Stop"

$rootDirectory = "$PSScriptRoot/../.."
$solutionPath = "$rootDirectory/Solution"
$solutionExportPath = "$solutionPath/Export"
$solutionXmlPath = "$solutionExportPath/Other/Solution.xml"

$solutionXml = Load-SolutionXml -xmlPath $solutionXmlPath
$canvasAppComponent = Get-CanvasAppComponent -solutionXml $solutionXml

$msAppName = $canvasAppComponent.schemaName
$msAppRelativePath = "CanvasApps\$($msAppName)_DocumentUri.msapp"

$appExportLocation = Join-Path $solutionExportPath $msAppRelativePath
$tempAppExportLocation = [System.IO.Path]::GetTempFileName() + '.zip'
$appSourceDirectory = Join-Path $rootDirectory "CanvasAppSource\*"

Compress-AppSource -sourceDirectory $appSourceDirectory -destinationPath $tempAppExportLocation
Remove-Directory -directoryPath $appExportLocation
Copy-Item $tempAppExportLocation $appExportLocation -Force

$relativeMsAppPathFromRoot = "Solution/Export/$msAppRelativePath"
Write-Output "Successfully packed canvas msapp in $relativeMsAppPathFromRoot"
