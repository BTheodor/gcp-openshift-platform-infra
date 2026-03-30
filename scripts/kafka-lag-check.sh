#!/bin/bash
set -euo pipefail

# Configuration
BOOTSTRAP_SERVER=${1:-"localhost:9092"}
LAG_THRESHOLD=${2:-1000}
CHECK_GROUPS=("campaign-processor-group" "analytics-ingestion-group" "public-api-sync-group")

echo "--- Kafka Consumer Lag Report ---"
echo "Threshold: $LAG_THRESHOLD"
printf "%-30s %-20s %-10s\n" "GROUP" "TOPIC" "LAG"

FAILED=0

for GROUP in "${CHECK_GROUPS[@]}"; do
    # Capture the lag using kafka-consumer-groups.sh
    # We grep for the group and then sum the lag across all partitions
    TOTAL_LAG=$(kafka-consumer-groups.sh --bootstrap-server "$BOOTSTRAP_SERVER" --describe --group "$GROUP" 2>/dev/null | awk 'NR>2 {sum+=$6} END {print sum}')

    if [[ -z "$TOTAL_LAG" ]]; then
        echo "Warning: Could not fetch lag for $GROUP (maybe the group doesn't exist?)"
        continue
    fi

    printf "%-30s %-20s %-10s\n" "$GROUP" "ALL" "$TOTAL_LAG"

    if [ "$TOTAL_LAG" -gt "$LAG_THRESHOLD" ]; then
        echo "Error: $GROUP lag ($TOTAL_LAG) exceeds threshold ($LAG_THRESHOLD)!"
        FAILED=1
    fi
done

if [ $FAILED -eq 1 ]; then
    echo "Check FAILED"
    exit 1
else
    echo "Check PASSED"
    exit 0
fi
