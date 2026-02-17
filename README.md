AWS Highly Available Infrastructure using Terraform

📌 Overview

This project provisions a production-style, highly available AWS infrastructure using Terraform.
It demonstrates Infrastructure as Code (IaC) best practices, secure networking design, and remote state management suitable for team environments.

The architecture is deployed across multiple Availability Zones to ensure high availability and scalability.
<img width="611" height="481" alt="image" src="https://github.com/user-attachments/assets/3b24f7d7-a3bf-4ca9-947d-da981b3e6284" />

🏗 Architecture Components
- Custom VPC (Multi-AZ)
- Public and Private Subnets
- Internet Gateway
- Highly Available NAT Gateways
- Application Load Balancer (ALB)
- Auto Scaling Group (ASG)
- Launch Template running NGINX
- Remote Terraform Backend (S3)
- State Locking using DynamoDB

🔐 Security & Best Practices
- EC2 instances deployed in private subnets
- Traffic routed through Application Load Balancer
- Security Group referencing (ALB → EC2)
- Encrypted S3 backend (AES256)
- S3 versioning enabled for state recovery
- DynamoDB state locking to prevent concurrent modifications
- Public access blocked for backend storage

📌 Outcome

Successfully deployed a production-style AWS architecture with scalable compute resources, secure networking, and team-ready Terraform backend configuration.

Final output

<img width="1554" height="498" alt="image" src="https://github.com/user-attachments/assets/42a2a2fe-c529-4825-9ae8-d0456cca790e" />
