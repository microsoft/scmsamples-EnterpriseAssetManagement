# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

. "$PSScriptRoot/../utils/FileUtils.ps1"
. "$PSScriptRoot/../utils/PowerAppsUtils.ps1"

$SolutionName = "msdyn_AssetManagementMobileSolution"
$ManagedSolutionName = "$SolutionName" + "_managed.zip"
$SolutionExportPath = "$PSScriptRoot/../../Solution/Export"
$binPath = "$PSScriptRoot/../../bin"
$UnmanagedSolutionPath = "$binPath/$SolutionName.zip"
$ManagedSolutionPath = "$binPath/$ManagedSolutionName"

Remove-Directory -directoryPath $binPath

Pack-Solution -solutionPath $UnmanagedSolutionPath -exportPath $SolutionExportPath -solutionType Unmanaged
Pack-Solution -solutionPath $ManagedSolutionPath -exportPath $SolutionExportPath -solutionType Managed

$unmanagedSolutionExists = Test-Path $UnmanagedSolutionPath
$managedSolutionExists = Test-Path $ManagedSolutionPath

if ($unmanagedSolutionExists -And $managedSolutionExists) {
    Write-Output "Successfully packed solutions in bin/$ManagedSolutionName and bin/$SolutionName.zip"
} else {
    Write-Error "Failed to package solutions"
    if (-not $unmanagedSolutionExists) {
        Write-Output "Unmanaged solution not found at $UnmanagedSolutionPath"
    }
    if (-not $managedSolutionExists) {
        Write-Output "Managed solution not found at $ManagedSolutionPath"
    }
    exit 1
}
