$SolutionName = "AssetManagementMobileSolution"
$SolutionPath = "$PSScriptRoot\..\Solution"
$SolutionExportPath = "$SolutionPath\Export"
$UnamanagedSolutionPath = "$SolutionPath\release\$SolutionName.zip"
$ManagedSolutionName = "$SolutionName" + "_managed"
$ManagedSolutionPath = "$SolutionPath\release\$ManagedSolutionName.zip"

pac solution pack -z $UnamanagedSolutionPath -f $SolutionExportPath -p Unmanaged -loc
& pac solution pack -z $ManagedSolutionPath -f $SolutionExportPath -p Managed -loc