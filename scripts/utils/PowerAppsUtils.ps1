function Load-SolutionXml {
    param (
        [string]$xmlPath
    )
    if (Test-Path $xmlPath) {
        try {
            return Get-Content $xmlPath
        } catch {
            Write-Error "Failed to load XML content from $xmlPath"
            exit 1
        }
    } else {
        Write-Error "Solution XML file not found at $xmlPath"
        exit 1
    }
}

function Get-CanvasAppComponent {
    param (
        [xml]$solutionXml
    )
    $canvasAppComponent = $solutionXml.ImportExportXml.SolutionManifest.RootComponents.RootComponent | Where-Object { $_.type -eq '300' }
    if ($null -eq $canvasAppComponent) {
        Write-Error "Canvas app component not found in solution XML"
        exit 1
    }
    return $canvasAppComponent
}

function Pack-Solution {
    param (
        [string]$solutionPath,
        [string]$exportPath,
        [string]$solutionType
    )
    try {
        pac solution pack -z $solutionPath -f $exportPath -p $solutionType -loc
    } catch {
        Write-Error "Failed to pack $solutionType solution at $solutionPath"
        exit 1
    }
}