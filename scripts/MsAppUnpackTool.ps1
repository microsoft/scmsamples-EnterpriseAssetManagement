param(
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path $_ })]
    [string] $MsAppPath
)

$RepoRoot = "$PSScriptRoot\.."
$sourcePath = "$RepoRoot\CanvasAppSource"

Remove-Item -Recurse $sourcePath -Force -ErrorAction SilentlyContinue

if ($MsAppPath -like '*.msapp') {
    $msAppAsZipTempPath = [System.IO.Path]::GetTempPath() + (Split-Path $MsAppPath -Leaf) + ".zip"
    Copy-Item -Path $MsAppPath -Destination $msAppAsZipTempPath
    $MsAppPath = $msAppAsZipTempPath
}

Expand-Archive -Path $MsAppPath -DestinationPath $sourcePath

& "$PSScriptRoot\Remove-SecretUrisFromAppSource.ps1"