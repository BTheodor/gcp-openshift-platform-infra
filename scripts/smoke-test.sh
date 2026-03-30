#!/bin/bash
set -euo pipefail

NAMESPACE=${1:-"prod"}
SERVICE_NAME=${2:-"campaign-service"}
READY_TIMEOUT=300

echo "Starting smoke tests for $SERVICE_NAME in namespace $NAMESPACE..."

# 1. Check Pod Readiness
echo "Checking pod readiness..."
kubectl wait --for=condition=Ready pods -l app.kubernetes.io/name=$SERVICE_NAME -n $NAMESPACE --timeout=${READY_TIMEOUT}s

# 2. Call Health Actuator
echo "Verifying service health endpoint..."
POD_NAME=$(kubectl get pods -l app.kubernetes.io/name=$SERVICE_NAME -n $NAMESPACE -o jsonpath='{.items[0].metadata.name}')
HEALTH_STATUS=$(kubectl exec -n $NAMESPACE $POD_NAME -- curl -s http://localhost:8080/actuator/health)

if [[ $HEALTH_STATUS == *"\"status\":\"UP\""* ]]; then
    echo "Health check passed: Service is UP"
else
    echo "Health check FAILED: $HEALTH_STATUS"
    exit 1
fi

# 3. Check Kafka Connectivity via Actuator
echo "Checking Kafka connectivity..."
if [[ $HEALTH_STATUS == *"\"kafka\":{\"status\":\"UP\""* ]]; then
    echo "Kafka connectivity verified"
else
    echo "Kafka connectivity FAILED"
    exit 1
fi

# 4. Check Redis Connectivity via Actuator
echo "Checking Redis connectivity..."
if [[ $HEALTH_STATUS == *"\"redis\":{\"status\":\"UP\""* ]]; then
    echo "Redis connectivity verified"
else
    echo "Redis connectivity FAILED"
    exit 1
fi

echo "All smoke tests PASSED for $SERVICE_NAME"
exit 0
