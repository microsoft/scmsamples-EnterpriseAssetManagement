# Canvas App Linter Script

## Description
This script analyzes a Canvas App solution for common issues and coding standard violations. It checks for unused components, invalid screen names, static labels that cannot be translated, unused translation labels, and needless use of `CountRows` where `IsEmpty` would suffice.

## Prerequisite
[Cloudbase Powershell yaml](https://github.com/cloudbase/powershell-yaml/tree/master)

## Usage
- Provide the path to the solution directory as a parameter.
- Run the script to lint the Canvas App.

### Example
```powershell
.\LintCanvasApp.ps1 -SolutionPath "C:\Path\To\Solution"
```