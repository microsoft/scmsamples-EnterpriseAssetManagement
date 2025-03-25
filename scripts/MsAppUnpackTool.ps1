param(
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path $_ })]
    [string] $MsAppPath
)

$RepoRoot = "$PSScriptRoot\..\*"
$reviewSourcePath = "$RepoRoot\CanvasAppReviewSource"
$sourcePath = "$RepoRoot\CanvasAppSource"

Remove-Item -Recurse $reviewSourcePath
Remove-Item -Recurse $sourcePath

& pac.exe canvas unpack --msapp $MsAppPath --sources $reviewSourcePath

if ($MsAppPath -like '*.msapp') {
    $msAppAsZipTempPath = [System.IO.Path]::GetTempPath() + (Split-Path $MsAppPath -Leaf) + ".zip"
    Copy-Item -Path $MsAppPath -Destination $msAppAsZipTempPath
    $MsAppPath = $msAppAsZipTempPath
}

Expand-Archive -Path $MsAppPath -DestinationPath $sourcePath

& "./Remove-SecretUrisFromAppSource.ps1"
