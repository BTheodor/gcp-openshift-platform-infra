# Runbook: Kafka Consumer Lag Mitigation

## Symptoms
- Alert: `KafkaConsumerLagCritical` fired.
- Application processing delays for campaign/analytics events.
- Metrics show `kafka_consumergroup_lag > 50,000` messages.

## Diagnosis
1.  **Verify Lag via CLI:**
    ```bash
    kafka-consumer-groups.sh --bootstrap-server $KAFKA_BROKER --describe --group campaign-processor-group
    ```
2.  **Check Consumer Pod Status:**
    ```bash
    kubectl get pods -n prod -l app.kubernetes.io/name=campaign-service
    ```
3.  **Inspect Logs for GC/Errors:**
    ```bash
    kubectl logs -n prod -l app.kubernetes.io/name=campaign-service --tail=100 | grep -iE "error|exception|gc"
    ```
4.  **Analyze Resource Consumption:** Check Grafana dashboard for CPU/Memory saturation in the consumer pods.

## Remediation
- **Option A: Horizontal Scaling (Preferred)**
    - If CPU/Memory is high, increase replicas: `kubectl scale deployment campaign-service -n prod --replicas=15`
    - Verify that new pods have successfully joined the consumer group and are processing partitions.
- **Option B: JVM Tuning**
    - If logs show frequent Full GC, increase heap via Helm: `helm upgrade ... --set resources.limits.memory=8Gi`
- **Option C: Reset Offsets (Emergency Only)**
    - If lag is due to poison pill messages, reset offsets to `latest`:
    ```bash
    kafka-consumer-groups.sh --bootstrap-server $KAFKA_BROKER --group campaign-processor-group --reset-offsets --to-latest --execute --topic campaigns
    ```

## Escalation Path
- If lag continues to grow despite scaling, contact the Messaging/Kafka platform team.
- If data loss is suspected, notify the Data Compliance officer.
