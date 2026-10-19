# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

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

    $archive = $null

    try {
        Add-Type -AssemblyName System.IO.Compression.FileSystem

        $destinationRoot = [System.IO.Path]::GetFullPath($destinationPath)
        $directorySeparators = [char[]]@(
            [System.IO.Path]::DirectorySeparatorChar,
            [System.IO.Path]::AltDirectorySeparatorChar
        )
        $destinationPrefix = $destinationRoot.TrimEnd($directorySeparators) + [System.IO.Path]::DirectorySeparatorChar
        $invalidFileNameChars = [System.IO.Path]::GetInvalidFileNameChars()
        $destinationPaths = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
        $filePaths = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
        $validatedEntries = @()

        $archivePath = (Resolve-Path -LiteralPath $msAppPath -ErrorAction Stop).ProviderPath
        $archive = [System.IO.Compression.ZipFile]::OpenRead($archivePath)

        foreach ($entry in $archive.Entries) {
            $entryName = $entry.FullName
            $normalizedEntryName = $entryName.Replace(
                [System.IO.Path]::AltDirectorySeparatorChar,
                [System.IO.Path]::DirectorySeparatorChar)
            $relativePath = $normalizedEntryName.TrimEnd([System.IO.Path]::DirectorySeparatorChar)

            if ([string]::IsNullOrWhiteSpace($relativePath) -or
                [System.IO.Path]::IsPathRooted($normalizedEntryName)) {
                throw "Unsafe archive entry path: $entryName"
            }

            foreach ($pathSegment in $relativePath.Split([System.IO.Path]::DirectorySeparatorChar)) {
                if ([string]::IsNullOrEmpty($pathSegment) -or
                    $pathSegment -eq '.' -or
                    $pathSegment -eq '..' -or
                    $pathSegment.EndsWith('.') -or
                    $pathSegment.EndsWith(' ') -or
                    $pathSegment -match '^(?i:CON|PRN|AUX|NUL|COM[1-9]|LPT[1-9])(\..*)?$' -or
                    $pathSegment.IndexOfAny($invalidFileNameChars) -ge 0) {
                    throw "Unsafe archive entry path: $entryName"
                }
            }

            $targetPath = [System.IO.Path]::GetFullPath(
                [System.IO.Path]::Combine($destinationRoot, $relativePath))

            if (-not $targetPath.StartsWith(
                    $destinationPrefix,
                    [System.StringComparison]::OrdinalIgnoreCase) -or
                -not $destinationPaths.Add($targetPath)) {
                throw "Archive entry escapes or duplicates the destination: $entryName"
            }

            $isDirectory = [string]::IsNullOrEmpty($entry.Name)
            if (-not $isDirectory) {
                $filePaths.Add($targetPath) | Out-Null
            }

            $validatedEntries += [pscustomobject]@{
                Entry = $entry
                TargetPath = $targetPath
                IsDirectory = $isDirectory
            }
        }

        foreach ($validatedEntry in $validatedEntries) {
            $parentPath = [System.IO.Path]::GetDirectoryName($validatedEntry.TargetPath)
            while ($parentPath.StartsWith(
                    $destinationPrefix,
                    [System.StringComparison]::OrdinalIgnoreCase)) {
                if ($filePaths.Contains($parentPath)) {
                    throw "Archive entry conflicts with a file path: $($validatedEntry.Entry.FullName)"
                }

                $parentPath = [System.IO.Path]::GetDirectoryName($parentPath)
            }
        }

        Remove-Directory -directoryPath $destinationRoot
        [System.IO.Directory]::CreateDirectory($destinationRoot) | Out-Null

        foreach ($validatedEntry in $validatedEntries) {
            if ($validatedEntry.IsDirectory) {
                [System.IO.Directory]::CreateDirectory($validatedEntry.TargetPath) | Out-Null
                continue
            }

            $targetDirectory = [System.IO.Path]::GetDirectoryName($validatedEntry.TargetPath)
            [System.IO.Directory]::CreateDirectory($targetDirectory) | Out-Null
            [System.IO.Compression.ZipFileExtensions]::ExtractToFile(
                $validatedEntry.Entry,
                $validatedEntry.TargetPath,
                $false)
        }
    } catch {
        Write-Error "Failed to expand archive from $msAppPath to $destinationPath. $($_.Exception.Message)"
        exit 1
    } finally {
        if ($null -ne $archive) {
            $archive.Dispose()
        }
    }
}
