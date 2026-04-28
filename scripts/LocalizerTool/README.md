# Translation Script

## Description
This script processes translation files in `.resx` format, converts them into a Power Fx compatible format, and optionally copies the result to the clipboard. It ensures that all translations are properly formatted and handles special cases such as significant whitespace and empty values.

## Usage
- Run the script with the optional `-CopyToClipboard` switch to copy the output to the clipboard.
### Example
```powershell
.\LocalizerTool.ps1 -CopyToClipboard
```
