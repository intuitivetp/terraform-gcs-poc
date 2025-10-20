# online-banking Architecture

Auto-generated architecture diagrams from Terraform configuration.

## Architecture Overview

Complete infrastructure visualization showing all resources and their relationships.

```mermaid
graph TB

    subgraph Other
        google_project_service_required_apis[🔧 Required_Apis]
        google_storage_bucket_object_index[🔧 Index]
        random_id_db_suffix[🔧 Db_Suffix]
        random_password_db_password[🔧 Db_Password]
        google_sql_user_banking_user[🔧 Banking_User]
    end

    subgraph Monitoring
        google_monitoring_dashboard_banking_dashboard[📊 Banking_Dashboard]
        google_logging_project_sink_banking_logs[📝 Banking_Logs]
    end

    subgraph Storage
        google_storage_bucket_documents[📦 Documents]
        google_storage_bucket_frontend[📦 Frontend]
    end

    subgraph IAM
        google_storage_bucket_iam_member_backend_access[🔧 Backend_Access]
        google_service_account_backend[👤 Backend]
        google_cloud_run_service_iam_member_public_access[🔧 Public_Access]
        google_project_iam_member_sql_client[🔧 Sql_Client]
        google_storage_bucket_iam_member_public_read[🔧 Public_Read]
    end

    subgraph Compute
        google_cloud_run_service_api[🚀 Api]
    end

    subgraph Database
        google_sql_database_instance_postgres[🗄️ Postgres]
        google_sql_database_banking[💾 Banking<br/>banking]
    end

    %% Dependencies

    %% Styling
    style google_project_service_required_apis fill:#607d8b,stroke:#333,color:#fff
    style google_monitoring_dashboard_banking_dashboard fill:#9c27b0,stroke:#333,color:#fff
    style google_logging_project_sink_banking_logs fill:#9c27b0,stroke:#333,color:#fff
    style google_storage_bucket_documents fill:#4285f4,stroke:#333,color:#fff
    style google_storage_bucket_iam_member_backend_access fill:#ea4335,stroke:#333,color:#fff
    style google_service_account_backend fill:#ea4335,stroke:#333,color:#fff
    style google_cloud_run_service_api fill:#34a853,stroke:#333,color:#fff
    style google_cloud_run_service_iam_member_public_access fill:#ea4335,stroke:#333,color:#fff
    style google_project_iam_member_sql_client fill:#ea4335,stroke:#333,color:#fff
    style google_storage_bucket_frontend fill:#4285f4,stroke:#333,color:#fff
    style google_storage_bucket_iam_member_public_read fill:#ea4335,stroke:#333,color:#fff
    style google_storage_bucket_object_index fill:#607d8b,stroke:#333,color:#fff
    style random_id_db_suffix fill:#607d8b,stroke:#333,color:#fff
    style google_sql_database_instance_postgres fill:#fbbc04,stroke:#333,color:#fff
    style google_sql_database_banking fill:#fbbc04,stroke:#333,color:#fff
    style random_password_db_password fill:#607d8b,stroke:#333,color:#fff
    style google_sql_user_banking_user fill:#607d8b,stroke:#333,color:#fff
```

## Network Topology

Network flow and connectivity between components.

```mermaid
graph LR

    Internet([Internet]) --> LB[Load Balancer]
    LB --> Frontend[Frontend]
    Frontend --> API[API Backend]
    API --> DB[(Database)]
    API --> Storage[Document Storage]

    style Internet fill:#f9f,stroke:#333
    style Frontend fill:#4285f4,stroke:#333,color:#fff
    style API fill:#34a853,stroke:#333,color:#fff
    style DB fill:#fbbc04,stroke:#333,color:#fff
    style Storage fill:#4285f4,stroke:#333,color:#fff
```

## Data Flow

Data movement and processing paths through the system.

```mermaid
graph TD

    User([User]) --> Frontend[Frontend UI]
    Frontend --> API[API Service]
    API --> Auth{Authentication}
    Auth -->|Valid| DB[(Database)]
    Auth -->|Invalid| Error[Error Response]
    DB --> Cache[(Cache Layer)]
    Cache --> API
    API --> Storage[Document Storage]
    API --> Logs[Cloud Logging]
    API --> Metrics[Cloud Monitoring]

    style User fill:#f9f,stroke:#333
    style Auth fill:#ea4335,stroke:#333,color:#fff
    style DB fill:#fbbc04,stroke:#333,color:#fff
```

---

**Generated**: ${TIMESTAMP}  
**Stack**: online-banking  
**Workflow**: IaC to Visual Pipeline (AI-Enhanced)  
**Run**: 31  
**Commit**: f3a1760363336255578f4f906af515b28a2eb0e3
