# Cloud Infrastructure & Observability Project

[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=TU_PROYECTO&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=TU_PROYECTO)
[![Terraform Security](https://img.shields.io/badge/Security-tfsec-orange)](https://github.com/aquasecurity/tfsec)

Este repositorio contiene la automatización completa para el despliegue de una infraestructura escalable en AWS, integrando prácticas de **CI/CD**, **IAAC** y **Observabilidad**.

## 🏗️ Arquitectura de la Solución
La infraestructura se gestiona mediante **Terraform** y se configura con **Ansible**:
* **Cómputo:** Instancias EC2 con Roles IAM restrictivos.
* **Red:** VPC personalizada con filtrado de seguridad (Security Groups).
* **Estado:** Remote State almacenado de forma segura en **Amazon S3**.
* **Observabilidad:** Dashboards de CloudWatch y agentes de logs (CloudWatch Agent).



---

## 🛠️ Stack Tecnológico
* **IaC:** Terraform
* **Config Management:** Ansible
* **CI/CD:** GitHub Actions
* **Code Quality:** SonarCloud (SonarQube)
* **Cloud:** Amazon Web Services (AWS)

---

## 🔒 Buenas Prácticas de Seguridad (DevSecOps)

### 1. Principio de Menor Privilegio (PoLP)
| Entidad | Nivel de Acceso | Justificación |
| :--- | :--- | :--- |
| **EC2 IAM Role** | ReadOnly (Secrets), WriteOnly (Logs) | Evita la manipulación no autorizada de otros recursos. |
| **SSH Access** | Port 22 Restricted | El acceso administrativo está filtrado por IP específica. |

### 2. Análisis Estático (SAST)
* **SonarCloud:** Análisis de calidad de código y detección de *code smells*.
* **tfsec:** Escaneo de seguridad preventivo sobre el código de Terraform para evitar malas configuraciones de red o permisos.



---

## 📂 Estructura del Proyecto
```text
├── .github/workflows   # Pipelines de CI/CD (Deploy & Destroy)
├── ansible/            # Playbooks y roles para configuración de software
├── terraform/          # Código de infraestructura por módulos
│   ├── modules/        # Recursos reutilizables (VPC, EC2, CloudWatch)
│   └── main.tf         # Punto de entrada de Terraform
└── SECURITY_REVIEW.md  # Reporte de cumplimiento de seguridad