$SolutionName = "msdyn_AssetManagementMobileSolution"
$ManagedSolutionName = "$SolutionName" + "_managed.zip"
$SolutionExportPath = "$PSScriptRoot/../Solution/Export"
$binPath = "$PSScriptRoot/../bin"
$UnamanagedSolutionPath = "$binPath/$SolutionName.zip"
$ManagedSolutionPath = "$binPath/$ManagedSolutionName"

Remove-Item -Recurse $binPath -Force -ErrorAction SilentlyContinue

pac solution pack -z $UnamanagedSolutionPath -f $SolutionExportPath -p Unmanaged -loc
& pac solution pack -z $ManagedSolutionPath -f $SolutionExportPath -p Managed -loc

$unmanagedSolutionExists = Test-Path $UnamanagedSolutionPath
$managedSolutionExists = Test-Path $ManagedSolutionPath
if ($unmanagedSolutionExists -And $managedSolutionExists) {
    Write-Output "Sucessfully packed solutions in bin/$ManagedSolutionName and bin/$SolutionName.zip"
} else {
    Write-Output "Failed to pack solutions in bin/$ManagedSolutionName and bin/$SolutionName.zip"
    if (-not $unmanagedSolutionExists) {
        Write-Output "Unmanaged solution not found at $UnamanagedSolutionPath"
    }
    if (-not $managedSolutionExists) {
        Write-Output "Managed solution not found at $ManagedSolutionPath"
    }
    exit 1
}