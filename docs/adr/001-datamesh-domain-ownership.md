# ADR 001: DataMesh Domain Ownership

## Status
Accepted

## Context
Our centralized data warehouse was becoming a bottleneck. Data engineering teams were disconnected from the business context of the data they were processing, leading to quality issues and slow turnaround times for new analytics requests. The platform processes 40M+ events daily across multiple functional areas (Campaign, Analytics, User Management).

## Decision
We will adopt a DataMesh architecture where data ownership is federated to individual domain teams. Each domain is responsible for:
1.  **Data as a Product:** Providing high-quality, discoverable, and secure data via standardized interfaces (e.g., BigQuery datasets, Kafka topics).
2.  **Infrastructure as a Self-Service:** Utilizing a centralized platform (GKE/OpenShift) to host their data processing workloads (Spring Boot, Hadoop).
3.  **Governance:** Adhering to global policies for metadata, security (Workload Identity), and compliance.

## Consequences
- **Positive:** Increased development velocity for domain teams; improved data quality through local accountability; reduced load on the central data team.
- **Negative:** Increased overhead for domain teams to manage their own data pipelines; requirement for a robust self-service platform to prevent fragmentation.
- **Compliance:** Each domain must implement PII masking at the source before publishing data to common domains.
