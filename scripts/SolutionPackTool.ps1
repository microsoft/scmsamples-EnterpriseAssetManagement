$SolutionName = "AssetManagementMobileSolution"
$SolutionPath = "../Solution"
$SolutionExportPath = "$SolutionPath/Export"
$UnamanagedSolutionPath = "../bin/$SolutionName.zip"
$ManagedSolutionName = "$SolutionName" + "_managed"
$ManagedSolutionPath = "../bin/$ManagedSolutionName.zip"

pac solution pack -z $UnamanagedSolutionPath -f $SolutionExportPath -p Unmanaged -loc
& pac solution pack -z $ManagedSolutionPath -f $SolutionExportPath -p Managed -loc