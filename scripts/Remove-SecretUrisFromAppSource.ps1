$ErrorActionPreference = "Stop"

Write-Host "Removing PCF bundle shared access signature from ReviewSource and CanvasAppSource"
$paths = @(
    "$PSScriptRoot\..\CanvasAppSource\*.json",
)

if (!(Test-Path "$PSScriptRoot\..\CanvasAppReviewSource")) {
    Write-Host "CanvasAppReviewSource folder not found. Skipping."
    $paths = $paths | Where-Object { $_ -notlike "*CanvasAppReviewSource*" }
}

if (!(Test-Path "$PSScriptRoot\..\CanvasAppSource")) {
    Write-Host "CanvasAppSource folder not found. Skipping."
    $paths = $paths | Where-Object { $_ -notlike "*CanvasAppSource*" }
}
if ($paths.Count -eq 0) {
    Write-Host "No source folders found. Skipping."
    exit
}



Get-ChildItem -Recurse -Path $paths `
| Where-Object {
    # entropy folder is ignored by Git, so no reason to peer
    $_.FullName -notlike '*Entropy*'
} `
| Select-String -Pattern "((\?|&)(sv|sig)=)" `
| Select-Object -Unique -ExpandProperty Path `
| ForEach-Object {
    $filePath = $_
    $fileContents = Get-Content -Raw -Encoding UTF8 -Path $filePath

    $fileContents = $fileContents -replace "(\?|&)sv=.+?&sp=[rw]{1,2}", ""
    $fileContents = $fileContents -replace "(\?|&)sig=[%\w]+", ""

    # Do not use `Set-Content -Encoding UTF8` because it adds a BOM
    [IO.File]::WriteAllLines($filePath, $fileContents)
}
