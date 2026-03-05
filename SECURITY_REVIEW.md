# Security & Access Review

## 1. Network Security Baseline
| Requirement | Rule Applied | Status |
| :--- | :--- | :--- |
| HTTP Traffic (80) | Allowed from 0.0.0.0/0 (ALB) | ✅ Compliant |
| SSH Traffic (22) | Allowed ONLY from Admin IP | ✅ Compliant |
| Outbound Traffic | All allowed for updates | ✅ Compliant |

## 2. Identity & Access Management (IAM)
- **Role:** `ec2_role`
- **Policy:** `CloudWatchAgentServerPolicy` (Least Privilege)
- **Review:** The role is restricted to pushing metrics and logs. No Administrative or S3 delete permissions are granted.

## 3. Least Privilege Verification
The CloudWatch Agent runs under the service account `cwagent`, not as `root`. 
Authentication is performed via SSH Keys (RSA 4096), with password authentication disabled.