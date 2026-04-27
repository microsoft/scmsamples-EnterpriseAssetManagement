# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

param (
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path $_ })]
    [string] $SolutionZipPath
)

$ErrorActionPreference = "Stop"

. "$PSScriptRoot/../utils/PowerAppsUtils.ps1"

$RepoRoot = "$PSScriptRoot/../.."
$exportPath = "$RepoRoot/Solution/Export"

Unpack-Solution -solutionZipPath $SolutionZipPath -exportPath $exportPath
