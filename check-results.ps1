param(
    [string]$JtlFile = "results\stress.jtl"
)

# Check whether the JTL file exists
if (!(Test-Path $JtlFile)) {
    Write-Host "ERROR: JTL file not found: $JtlFile"
    exit 1
}

# Import JMeter CSV results
$results = Import-Csv -Path $JtlFile

# Exclude parent transaction
$apiResults = @(
    $results | Where-Object {
        $_.label -ne "CRUD_Operations"
    }
)

$totalSamples = $apiResults.Count

if ($totalSamples -eq 0) {
    Write-Host "ERROR: No API samples found."
    exit 1
}

# Calculate failed requests
$failedSamples = @(
    $apiResults | Where-Object {
        $_.success -ne "true"
    }
).Count

# Calculate error rate
$errorRate = ($failedSamples / $totalSamples) * 100

# Calculate P95 response time
$responseTimes = @(
    $apiResults |
    ForEach-Object { [double]$_.elapsed } |
    Sort-Object
)

$index = [Math]::Ceiling(0.95 * $totalSamples) - 1
$p95 = $responseTimes[$index]

# Display results
Write-Host ""
Write-Host "========== PERFORMANCE RESULTS =========="
Write-Host "API Samples: $totalSamples"
Write-Host "Failed APIs: $failedSamples"
Write-Host "Error Rate: $([Math]::Round($errorRate, 2))%"
Write-Host "P95 Response Time: $p95 ms"
Write-Host "=========================================="

# Performance quality gate
if ($errorRate -gt 0 -or $p95 -gt 2000) {
    Write-Host "PERFORMANCE GATE: FAILED"
    exit 1
}

Write-Host "PERFORMANCE GATE: PASSED"
exit 0