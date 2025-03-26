. "$PSScriptRoot/../utils/FileUtils.ps1"
. "$PSScriptRoot/../utils/PowerAppsUtils.ps1"

$SolutionName = "msdyn_AssetManagementMobileSolution"
$ManagedSolutionName = "$SolutionName" + "_managed.zip"
$SolutionExportPath = "$PSScriptRoot/../../Solution/Export"
$binPath = "$PSScriptRoot/../../bin"
$UnamanagedSolutionPath = "$binPath/$SolutionName.zip"
$ManagedSolutionPath = "$binPath/$ManagedSolutionName"

Remove-Directory -directoryPath $binPath

Pack-Solution -solutionPath $UnamanagedSolutionPath -exportPath $SolutionExportPath -solutionType Unmanaged
Pack-Solution -solutionPath $ManagedSolutionPath -exportPath $SolutionExportPath -solutionType Managed

$unmanagedSolutionExists = Test-Path $UnamanagedSolutionPath
$managedSolutionExists = Test-Path $ManagedSolutionPath

if ($unmanagedSolutionExists -And $managedSolutionExists) {
    Write-Output "Successfully packed solutions in bin/$ManagedSolutionName and bin/$SolutionName.zip"
} else {
    Write-Error "Failed to package solutions"
    if (-not $unmanagedSolutionExists) {
        Write-Output "Unmanaged solution not found at $UnamanagedSolutionPath"
    }
    if (-not $managedSolutionExists) {
        Write-Output "Managed solution not found at $ManagedSolutionPath"
    }
    exit 1
}
