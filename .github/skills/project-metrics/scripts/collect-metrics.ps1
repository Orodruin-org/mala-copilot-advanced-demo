#!/usr/bin/env pwsh
# collect-metrics.ps1
# Outputs a JSON object with project health metrics.
# Run from the workspace root: pwsh -NoProfile -File .github/skills/project-metrics/scripts/collect-metrics.ps1

Set-StrictMode -Off
$ErrorActionPreference = 'Continue'

# ── Source files per layer ────────────────────────────────────────────────────
$layers = @('routers', 'services', 'repositories', 'utils', 'static')
$sourceFiles = @{}

foreach ($layer in $layers) {
    $path = Join-Path 'src' 'weather_app' $layer
    if (Test-Path $path) {
        $files = Get-ChildItem -Path $path -Filter '*.py' -Recurse |
                 Where-Object { $_.Name -ne '__init__.py' } |
                 Select-Object -ExpandProperty Name
        $sourceFiles[$layer] = @($files)
    } else {
        $sourceFiles[$layer] = @()
    }
}

# Root-level source files (models.py, main.py, etc.)
$rootSrc = Get-ChildItem -Path (Join-Path 'src' 'weather_app') -Filter '*.py' -File |
           Where-Object { $_.Name -ne '__init__.py' } |
           Select-Object -ExpandProperty Name
$sourceFiles['root'] = @($rootSrc)

# ── Test files per scope ──────────────────────────────────────────────────────
$testScopes = @('unit', 'integration')
$testFiles = @{}

foreach ($scope in $testScopes) {
    $path = Join-Path 'tests' $scope
    if (Test-Path $path) {
        $files = Get-ChildItem -Path $path -Filter 'test_*.py' -Recurse |
                 Select-Object -ExpandProperty Name
        $testFiles[$scope] = @($files)
    } else {
        $testFiles[$scope] = @()
    }
}

# ── Coverage gaps: source modules with no test file ───────────────────────────
$coverageGaps = @()
$allSourceModules = @()

foreach ($layer in ($layers + @('root'))) {
    foreach ($file in $sourceFiles[$layer]) {
        $module = [System.IO.Path]::GetFileNameWithoutExtension($file)
        $allSourceModules += $module
    }
}

$allTestModules = @()
foreach ($scope in $testScopes) {
    foreach ($file in $testFiles[$scope]) {
        # test_weather_service.py -> weather_service
        $module = [System.IO.Path]::GetFileNameWithoutExtension($file) -replace '^test_', ''
        $allTestModules += $module
    }
}

foreach ($module in $allSourceModules) {
    if ($module -notin $allTestModules) {
        $coverageGaps += $module
    }
}

# ── Dependencies ──────────────────────────────────────────────────────────────
$dependencies = @{}
try {
    $uvList = & uv pip list --format=json 2>$null | ConvertFrom-Json
    foreach ($pkg in $uvList) {
        $dependencies[$pkg.name] = $pkg.version
    }
} catch {
    $dependencies['_error'] = 'uv pip list failed or uv not found'
}

# ── Lint status ───────────────────────────────────────────────────────────────
$lintViolations = -1
$lintPassed = $false
try {
    $ruffRaw = uv run ruff check src/ tests/ --output-format=json 2>&1 |
               Where-Object { $_ -isnot [System.Management.Automation.ErrorRecord] } |
               Out-String
    if ([string]::IsNullOrWhiteSpace($ruffRaw)) { $ruffRaw = '[]' }
    $violations = $ruffRaw | ConvertFrom-Json
    $lintViolations = $violations.Count
    $lintPassed = ($lintViolations -eq 0)
} catch {
    $lintViolations = -1  # -1 = could not run
    $lintPassed = $false
}

# ── Assemble output ───────────────────────────────────────────────────────────
$result = [ordered]@{
    source_files   = $sourceFiles
    test_files     = $testFiles
    coverage_gaps  = $coverageGaps
    dependencies   = $dependencies
    lint_status    = [ordered]@{
        passed     = $lintPassed
        violations = $lintViolations
    }
}

$result | ConvertTo-Json -Depth 6
