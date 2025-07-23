param(
    [Parameter(Mandatory)]
    [ValidateScript({ Test-Path $_ })]
    [string] $SolutionPath
)

$ErrorActionPreference = "Stop"

Import-Module -Name $env:PKG_POWERSHELL_YAML/powershell-yaml.psm1 -NoClobber

class Lint {
    [bool] $IsError
    [string] $Description

    hidden Lint([string] $description, [bool] $isError) {
        $this.Description = $description
        $this.IsError = $isError
    }

    [Lint] static NewError([string] $Description) {
        return [Lint]::new($Description, $true)
    }

    [Lint] static NewWarning([string] $Description) {
        return [Lint]::new($Description, $false)
    }
}

function New-LinterRule {
    param (
        [string] $ID,
        [string] $Title,
        [scriptblock] $Detector
    )

    return [PSCustomObject]@{
        ID = $ID
        Title = $Title
        Detector = $Detector
    }
}

function Write-LinterWarning {
    param (
        [PSCustomObject] $Rule,
        [string] $Message
    )

    Write-Warning -Message "[$($Rule.ID)] $($Rule.Title): $Message"
}

function Write-LinterError {
    param (
        [PSCustomObject] $Rule,
        [string] $Message
    )

    # PowerShell's Write-Error is primarily for in-script errors, not for
    # reporting other types of errors. So use Console stderr instead.
    [Console]::ForegroundColor = [ConsoleColor]::Red
    [Console]::Error.WriteLine("ERROR: [$($Rule.ID)] $($Rule.Title): $Message")
    [Console]::ResetColor()
}

function Write-LinterDiagnostic {
    param (
        [PSCustomObject] $Rule,
        [Lint] $Lint
    )

    $writer = if ($Lint.IsError) { ${function:Write-LinterError} } else { ${function:Write-LinterWarning} }

    & $writer -Rule $Rule -Message $Lint.Description
}

$appReviewSourcePath = "$SolutionPath/CanvasAppReviewSource"

$componentsRaw = Get-Content -Raw -Path "$appReviewSourcePath/Src/Components/*.json"
$components = $componentsRaw | ConvertFrom-Json
$screensPaths = Get-Item -Path "$appReviewSourcePath/Src/*.fx.yaml"
$screensRaw = Get-Content -Raw -Path $screensPaths
$screens = $screensRaw | ConvertFrom-Yaml
[xml]$enUSTranslationXml = Get-Content -Raw "$PSScriptRoot/../../Translations/Labels.en-US.resx"

$linterRules = @{
    # PAL = Power Apps Linter (PA already exists as diagnostic ID prefix from PAC CLI)
    PAL001_UnusedComponent = New-LinterRule -ID 'PAL001' -Title 'Unused component' -Detector {
        $componentNames = $components.ComponentManifest.Name
        $unusedComponentsLint = @()

        foreach ($componentName in $componentNames) {
            $isInUse = $false
            foreach ($screen in $screensRaw) {
                if ($screen -cmatch "As $componentName") {
                    $isInUse = $true
                    break
                }
            }

            if (-not $isInUse) {
                $unusedComponentsLint += [Lint]::NewWarning($componentName)
            }
        }

        return $unusedComponentsLint
    }
    PAL002_InvalidScreenName = New-LinterRule -ID 'PAL002' -Title 'Screen name not ending with " Screen"' -Detector {
        $invalidScreenNames = $screens.Keys `
            | Where-Object { $_ -like '* As screen' -and $_ -notlike "* Screen' As screen" } `
            | ForEach-Object { $_ -match "'?(.+?)'? As screen" | Out-Null; $screenName = $Matches[1]; $screenName }

        return $invalidScreenNames | ForEach-Object { [Lint]::NewError($_) }
    }

    PAL004_StaticLabelNoTranslate = New-LinterRule -ID 'PAL004' -Title 'Label is static or contains static ordering and cannot be translated' -Detector {
        $script:untranslatableLabelsLint = @()

        function DiscoverStaticallyAssignedLabel($Node) {
            if (-not $Node -or $Node.GetType().Name -ne "Hashtable") {
                return
            }

            foreach ($nodeName in $Node.Keys) {
                $currentNode = $Node.Item($nodeName)

                if ($nodeName.EndsWith(" As label")) {
                    $nodeText = $currentNode.Item("Text")
                    $hasStaticString = $nodeText.Contains('"')

                    if (-not $hasStaticString) { continue }

                    $hasRuleDisabled = $nodeText.Contains("pal-disable PAL004")
                    $hasSubstitution = $nodeText.Contains("Substitute(")

                    if ($hasRuleDisabled -or $hasSubstitution) { continue }

                    $script:untranslatableLabelsLint += [Lint]::NewWarning($nodeName)
                } else {
                    DiscoverStaticallyAssignedLabel -Node $currentNode
                }
            }
        }

        DiscoverStaticallyAssignedLabel($screens)

        return $script:untranslatableLabelsLint
    }
    PAL005_UnusedTranslationLabel = New-LinterRule -ID 'PAL005' -Title 'Unused translation label' -Detector {
        $unusedLabelsLint = @()
        $translationLabels = $enUSTranslationXml.root.data | Select-Object -Property name, value | Sort-Object -Property name
        $screensRawCombined = ($screensRaw | Where-Object { -not $_.StartsWith('App As appinfo') }) -join ' '

        foreach ($label in $translationLabels) {
            $isLabelUsed = $screensRawCombined.Contains("T.$($label.name)")
            if (-not $isLabelUsed) {
                $unusedLabelsLint += [Lint]::NewWarning("T.$($label.name): $($label.value)")
            }
        }

        return $unusedLabelsLint
    }
    PAL006_NeedlessCountRows = New-LinterRule -ID 'PAL006' -Title 'Needless CountRows can be replaced with IsEmpty' -Detector {
        $needlessCountRowsLint = @()

        foreach ($screenPath in $screensPaths) {
            $screenRaw = Get-Content -Raw -Path $screenPath

            if ($screenRaw -match '(?sm)CountRows\(.+?\)\s*(=|>)\s*0') {
                $screenName = Split-Path -Leaf $screenPath
                $needlessCountRowsLint += [Lint]::NewWarning($screenName)
            }
        }

        return $needlessCountRowsLint
    }
}

foreach ($linterRuleKey in $linterRules.Keys | Sort-Object) {
    $linterRule = $linterRules.$linterRuleKey
    $detectedLint = & $linterRule.Detector

    foreach ($lint in $detectedLint) {
        Write-LinterDiagnostic -Lint $lint -Rule $linterRule
    }
}
