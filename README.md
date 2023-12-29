# Assignment-Devops1

In this assignment, your task is to deploy an Amazon Relational Database Service (RDS) instance using Infrastructure as Code tool Terraform, adhering to AWS's best practices. Additionally, you will set up a Bastion host to manage access to your database securely.

A Bastion host acts as a secure, controlled entry point to your AWS environment from the internet. It is placed in a public subnet and is the only server exposed to the internet. Your RDS instance, on the other hand, will be located in a private subnet, accessible only via the Bastion host.

Your assignment will require using the following AWS services:
AWS RDS: To host your relational database.
Amazon EC2: To create the Bastion host.
Amazon VPC: For creating a virtual network within AWS, which will include a public subnet for the Bastion host and a private subnet for your RDS instance.
Security Groups: To control inbound and outbound traffic to your Bastion host and RDS instance.
AWS Identity and Access Management (IAM): To manage AWS service permissions.
AWS S3: For storing the Terraform state file.
You should take into account the following aspects:
Security: Ensure that the RDS instance is not publicly accessible and can only be reached through the Bastion host. Employ proper security groups and network access control lists (NACLs) for additional security.
Terraform: Use Terraform for deploying the RDS instance and the Bastion host. Remember to use resource dependencies where appropriate and parameterize your Terraform scripts to make them reusable.
Terraform State: The state of your Terraform deployment should be stored in an S3 bucket. You can create this S3 bucket manually. Remember to enable versioning on the bucket to maintain a history of state files.
RDS Best Practices: Configure the RDS instance following AWS's best practices for security.
Cost Effectiveness: This is a learning assignment. Ensure you use the smallest and lowest-cost resources to complete the assignment. Also, ensure that everything is created through Terraform, so it can be easily torn down after completing the assignment.
This assignment will give you hands-on experience with Terraform and AWS and challenge you to apply the best security and architecture practices you have learned. Please note that while we mention the services required, part of this assignment's challenge is figuring out how to use these services to achieve the desired outcome. Good luck!
