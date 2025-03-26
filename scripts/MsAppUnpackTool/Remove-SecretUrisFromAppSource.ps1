$ErrorActionPreference = "Stop"

Write-Host "Removing PCF bundle shared access signature from ReviewSource and CanvasAppSource"
$path = "$PSScriptRoot\..\..\CanvasAppSource"
$srcFiles = "$path\*.json"

if (!(Test-Path $path)) {
    Write-Host "CanvasAppSource folder not found. Skipping."
    exit
}

Get-ChildItem -Recurse -Path $srcFiles `
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
