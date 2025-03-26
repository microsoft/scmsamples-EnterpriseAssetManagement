# Canvas App Source Preparation Script

## Description
This script prepares the Canvas App source directory by removing existing content, copying the `.msapp` file to a temporary location if necessary, and expanding the archive into the source directory. It also executes an additional script to remove secret URIs from the app source.

## Usage
- Provide the path to the `.msapp` file as a parameter.
- Run the script to prepare the Canvas App source.
### Example
```powershell
.\PrepareCanvasAppSource.ps1 -MsAppPath "C:\Path\To\YourApp.msapp"