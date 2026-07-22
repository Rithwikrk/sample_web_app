# PowerShell equivalent of check_dependencies.sh
# Run on Windows natively without needing bash or WSL

param(
    [int]$Timeout = 5
)

$ErrorActionPreference = "Stop"

# Define your tools and their URLs
$Tools = @{
    "SonarQube" = "http://13.206.186.122:9000/"
    # Add other tools here as needed, for example:
    # "Nexus" = "http://13.206.186.122:8081/"
    # "Artifactory" = "http://13.206.186.122:8082/"
}

$MaxTime = $Timeout + 5
$FailedTools = 0

Write-Host "========================================="
Write-Host "Checking dependent tools status..."
Write-Host "========================================="

foreach ($Tool in $Tools.Keys) {
    $URL = $Tools[$Tool]
    Write-Host -NoNewline "Checking $Tool ($URL)... "

    try {
        # Use Invoke-WebRequest with timeout
        $response = Invoke-WebRequest -Uri $URL `
                                      -Method Head `
                                      -TimeoutSec $MaxTime `
                                      -SkipCertificateCheck `
                                      -ErrorAction Stop

        $StatusCode = $response.StatusCode

        # Treat 2xx and 3xx as acceptable; 401 as reachable though requires auth
        if (($StatusCode -ge 200 -and $StatusCode -lt 400) -or $StatusCode -eq 401) {
            Write-Host "✅ ONLINE (HTTP $StatusCode)"
        } else {
            Write-Host "❌ DOWN or UNREACHABLE (HTTP status: $StatusCode)"
            $FailedTools++
        }
    } catch {
        # Handle connection failures
        Write-Host "❌ UNREACHABLE (no response)"
        $FailedTools++
    }
}

Write-Host "========================================="
if ($FailedTools -eq 0) {
    Write-Host "All dependent tools are up and running."
    exit 0
} else {
    Write-Host "Warning: $FailedTools tool(s) failed the health check."
    exit 1
}
