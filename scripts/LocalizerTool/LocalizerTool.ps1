param(
    [switch] $CopyToClipboard
)

$ErrorActionPreference = 'Stop'

$translationFiles = Get-Item "$PSScriptRoot/../../Translations/Labels.*.resx" | Where-Object { $_.Name -ne 'Labels.en-US.resx' }
$translationFiles = @("$PSScriptRoot/../../Translations/Labels.en-US.resx") + $translationFiles

$translations = @()

[xml]$enUSTranslationXml = Get-Content -Raw "$PSScriptRoot/../../Translations/Labels.en-US.resx"
$enUSTranslationXmlData = $enUSTranslationXml.root.data | Select-Object -Property name, value | Sort-Object -Property name

foreach ($translationFile in $translationFiles) {
    if (-not ($translationFile -match 'Labels\.([\w-]+)\.resx')) {
        Write-Error "Invalid translation file name: $($translationFile.Name)"
    }

    $language = $Matches[1]
    [xml]$translationXml = Get-Content -Raw $translationFile -Encoding UTF8

    $translatedLabels = [ordered]@{}
    $translationXmlData = $translationXml.root.data | Select-Object -Property name, value | Sort-Object -Property name
    $enUSTranslationXmlData | ForEach-Object {
        $key = $_.name
        $translation = ($translationXmlData | Where-Object { $_.name -eq $key })

        $translatedLabels[$key] = if ($translation.value.'#significant-whitespace') {
            $translation.value.'#significant-whitespace'
        } elseif ($translation.value) {
            $translation.value
        } else {
            $_.value
        }

        if ($translatedLabels[$key] -eq '{Empty}') {
            $translatedLabels[$key] = ''
        }
    }

    $translations += [pscustomobject]@{ code=$language; labels=$translatedLabels }
}

$translationsPowerFxTableData = ConvertTo-Json -Compress -Depth 5 $translations
# replace key wrappers `"key":` with `key:`, which is the Power Fx'esque way to declare record keys
$translationsPowerFxTableData = $translationsPowerFxTableData -replace '"([^"]+?)":', '$1:'
# replace \" with "" since Power Apps escapes double quotes with ""
$translationsPowerFxTableData = $translationsPowerFxTableData  -replace '\\"', '""'
# replace \uXXXX unicode escape sequences since Power Apps does not understand those
$translationsPowerFxTableData = $translationsPowerFxTableData | ForEach-Object {
    [Regex]::Replace($_,
    "\\u(?<Value>[a-zA-Z0-9]{4})", {
        param($m) ([char]([int]::Parse($m.Groups['Value'].Value,
            [System.Globalization.NumberStyles]::HexNumber))).ToString() } )
}
# replace [ .. ] with Table( .. ), as some DV environments apparently don't know about the [] syntax
$translationsPowerFxTableData = "Table(" + $translationsPowerFxTableData.Substring(1, $translationsPowerFxTableData.Length - 2) + ")"

$translationPowerFx = "With({languages:$translationsPowerFxTableData},Set(gblAvailableLanguages,ForAll(languages,code));With({language:Coalesce(LookUp(languages,code=gblLanguageCode),LookUp(languages,code=`"en-US`"))},Set(gblLanguageCode,language.code);language.labels))"

if ($CopyToClipboard) {
    Set-Clipboard -Value $translationPowerFx
} else {
    Write-Output $translationPowerFx
}
