function Remove-Directory {
    param (
        [string]$directoryPath
    )
    if (Test-Path $directoryPath) {
        try {
            Remove-Item -Recurse $directoryPath -Force -ErrorAction SilentlyContinue
        } catch {
            Write-Error "Failed to remove directory at $directoryPath"
            exit 1
        }
    }
}

function Compress-AppSource {
    param (
        [string]$sourceDirectory,
        [string]$destinationPath
    )
    if (Test-Path $sourceDirectory) {
        try {
            Compress-Archive -Path $sourceDirectory -DestinationPath $destinationPath -Force
        } catch {
            Write-Error "Failed to compress app source directory at $sourceDirectory"
            exit 1
        }
    } else {
        Write-Error "App source directory not found at $sourceDirectory"
        exit 1
    }
}

function Prepare-MsAppPath {
    param (
        [string]$msAppPath
    )
    if ($msAppPath -like '*.msapp') {
        $msAppAsZipTempPath = [System.IO.Path]::GetTempPath() + (Split-Path $msAppPath -Leaf) + ".zip"
        try {
            Copy-Item -Path $msAppPath -Destination $msAppAsZipTempPath
            return $msAppAsZipTempPath
        } catch {
            Write-Error "Failed to copy msapp file to temporary path"
            exit 1
        }
    }
    return $msAppPath
}

function Expand-MsAppArchive {
    param (
        [string]$msAppPath,
        [string]$destinationPath
    )
    try {
        Expand-Archive -Path $msAppPath -DestinationPath $destinationPath
    } catch {
        Write-Error "Failed to expand archive from $msAppPath to $destinationPath"
        exit 1
    }
}
