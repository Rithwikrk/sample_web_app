#!/bin/bash

set -o pipefail
set -u

# Check prerequisites
if ! command -v curl >/dev/null 2>&1; then
    echo "ERROR: 'curl' is required but not installed or not in PATH."
    exit 2
fi

# Define your tools and their URLs in an associative array
declare -A TOOLS=(
    ["SonarQube"]="http://13.206.186.122:9000/"
    # Add other tools here as needed, for example:
    # ["Nexus"]="http://13.206.186.122:8081/"
    # ["Artifactory"]="http://13.206.186.122:8082/"
)

# Timeout in seconds for each request
TIMEOUT=${TIMEOUT:-5}
# Maximum time curl may take (timeout + buffer)
MAX_TIME=$((TIMEOUT + 5))
FAILED_TOOLS=0

echo "========================================="
echo "Checking dependent tools status..."
echo "========================================="

for TOOL in "${!TOOLS[@]}"; do
    URL="${TOOLS[$TOOL]}"
    printf "Checking %s (%s)... " "$TOOL" "$URL"

    # Use curl to get HTTP status code. Follow redirects (-L), show errors (-S),
    # set connect timeout and overall max time. Output body to /dev/null.
    STATUS_CODE=$(curl -sS -L -o /dev/null -w "%{http_code}" \
                  --connect-timeout "$TIMEOUT" --max-time "$MAX_TIME" "$URL") || STATUS_CODE="000"

    # If curl failed to connect it may return 000
    if [[ "$STATUS_CODE" == "000" ]]; then
        echo "❌ UNREACHABLE (no response)"
        ((FAILED_TOOLS++))
        continue
    fi

    # Treat 2xx and 3xx as acceptable; 401 is reported as reachable though requires auth
    if [[ "$STATUS_CODE" =~ ^2[0-9][0-9]$ ]] || [[ "$STATUS_CODE" =~ ^3[0-9][0-9]$ ]] || [[ "$STATUS_CODE" == "401" ]]; then
        echo "✅ ONLINE (HTTP $STATUS_CODE)"
    else
        echo "❌ DOWN or UNREACHABLE (HTTP status: $STATUS_CODE)"
        ((FAILED_TOOLS++))
    fi
done

echo "========================================="
if [ "$FAILED_TOOLS" -eq 0 ]; then
    echo "All dependent tools are up and running."
    exit 0
else
    echo "Warning: $FAILED_TOOLS tool(s) failed the health check."
    exit 1
fi