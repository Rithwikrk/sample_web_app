# check_dependencies — Tool Health Check Scripts

This directory contains scripts to verify that dependent tools (SonarQube, Nexus, Artifactory, etc.) are reachable and operational.

## Files

- **check_dependencies.sh** — Bash version (for Linux/Mac or WSL on Windows)
- **check_dependencies.ps1** — PowerShell version (for Windows native execution)

## Usage

### On Windows (PowerShell)

```powershell
# Run with default timeout (5 seconds)
.\script\check_dependencies.ps1

# Run with custom timeout (10 seconds)
.\script\check_dependencies.ps1 -Timeout 10
```

### On Linux/Mac or WSL

```bash
# Run with default timeout (5 seconds)
bash ./script/check_dependencies.sh

# Run with custom timeout (10 seconds)
TIMEOUT=10 bash ./script/check_dependencies.sh
```

### On Jenkins (Linux Agent)

The bash version is recommended:

```bash
bash ${WORKSPACE}/script/check_dependencies.sh
```

## Exit Codes

- **0** — All tools are reachable and online.
- **1** — One or more tools failed the health check.
- **2** — (Bash only) `curl` is not installed or not in PATH.

## Configuration

Edit the `TOOLS` associative array (bash) or `$Tools` hashtable (PowerShell) to add or modify tool URLs:

**Bash:**
```bash
declare -A TOOLS=(
    ["SonarQube"]="http://13.206.186.122:9000/"
    ["Nexus"]="http://13.206.186.122:8081/"
    ["Artifactory"]="http://13.206.186.122:8082/"
)
```

**PowerShell:**
```powershell
$Tools = @{
    "SonarQube" = "http://13.206.186.122:9000/"
    "Nexus" = "http://13.206.186.122:8081/"
    "Artifactory" = "http://13.206.186.122:8082/"
}
```

## Notes

- Timeouts are handled gracefully; unreachable tools are reported but don't hang the pipeline.
- The scripts treat HTTP 2xx, 3xx, and 401 (auth required) as "reachable."
- Bash version requires Bash 4.0+.
- PowerShell version uses `-SkipCertificateCheck` for self-signed TLS certificates.
