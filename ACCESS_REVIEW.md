## Security & Access Review: Least-Privilege Analysis

This section provides the data required for a least-privilege access review, demonstrating that both cloud and system-level permissions are restricted to the minimum necessary for the application to function.

### 1. Access Control Summary

| Entity | Access Level | Least Privilege Justification |
| :--- | :--- | :--- |
| **EC2 IAM Role** | ReadOnly (Secrets), WriteOnly (Logs) | No delete or management permissions for other AWS resources. |
| **cwagent User** | System User (nologin) | Cannot log in via shell; access is limited to logs via the `systemd-journal` group. |
| **Security Group** | Port 22 Filtered | Administrative access is restricted to a specific IP address, not open to the world. |

---

### 2. Security Comparison: Bad Practice vs. Applied Configuration

| Resource | Insecure Access (Bad Practice) | Applied (Least Privilege) |
| :--- | :--- | :--- |
| **CloudWatch** | `logs:*` on `Resource: *` | `Create/Put` actions restricted to specific log streams. |
| **Secrets Manager** | `secretsmanager:*` | `GetSecretValue` permission restricted to a specific secret name. |
| **SSH** | Port 22 open to `specific ip` | Port 22 restricted to a Trusted Admin IP. |



---

### 3. Implementation Details

* **IAM Policy:** The instance profile attached to the EC2 uses a custom policy that explicitly denies any action not related to log ingestion or secret retrieval.
* **Operating System:** The `amazon-cloudwatch-agent` runs under a dedicated `cwagent` service account. This account has no `sudo` privileges and no interactive shell (`/sbin/nologin`).
* **Networking:** Ingress rules are strictly defined in Terraform. The application is reachable on Port 80, while management access (Port 22) is restricted at the firewall level.

> **Conclusion:** The infrastructure follows the **Principle of Least Privilege (PoLP)**. By ensuring that each identity and resource has only the minimum permissions necessary, we successfully minimize the potential blast radius in the event of a credential compromise.
