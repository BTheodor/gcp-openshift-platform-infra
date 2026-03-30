# ADR 007: Redis to Replace Hazelcast for Distributed Caching

## Status
Accepted

## Context
Our existing Hazelcast cluster, running as an embedded library within Spring Boot microservices, is causing significant heap pressure and frequent Garbage Collection (GC) pauses (up to 500ms). This impact is particularly noticeable in the campaign-service during peak load. Scaling Hazelcast horizontally is also tightly coupled with application scaling, leading to inefficient resource utilization.

## Decision
We will migrate from embedded Hazelcast to an external Redis Sentinel cluster. Redis will be deployed as a dedicated infrastructure service, decoupled from application lifecycles.
1.  **Architecture:** Redis Sentinel for high availability (3 nodes + 3 sentinels).
2.  **Implementation:** Use Spring Data Redis with Lettuce as the client.
3.  **Migration Strategy:** Blue-Green deployment with a feature flag to toggle between Hazelcast and Redis.

## Consequences
- **Positive:** Reduced JVM heap pressure; predictable application performance; independent scaling of cache vs. compute; standardized observability via Prometheus Redis Exporter.
- **Negative:** Increased network latency for cache hits (from local memory to remote Redis); new infrastructure to manage and monitor.
- **Migration Plan:**
    1. Deploy Redis Sentinel in GCP/OpenShift.
    2. Update services to support dual-write to both caches (Hazelcast/Redis).
    3. Shift reads to Redis via feature flag.
    4. Decommission Hazelcast nodes.
