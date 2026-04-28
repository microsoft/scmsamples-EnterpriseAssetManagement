# Solution Source Preparation Script

## Description
This script unpacks an exported solution `.zip` into the repository's `Solution/Export/` directory, producing the granular per-component source layout used for round-tripping with PAC CLI.

## Usage
- Provide the path to the solution `.zip` as a parameter.
- Run the script to unpack the solution into the repository.

### Example
```powershell
.\SolutionUnpackTool.ps1 -SolutionZipPath "C:\Path\To\Solution.zip"
```
