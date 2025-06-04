# SCTP-CE9-Group 2 Capstone Infrastructure

This repository contains the Terraform code and Github Actions needed for creating the AWS Infrastructure for our Capstone Project

## RESOURCES

- VPC with Public and Private Subnets across 3 AZs 
- Internet Gateway and NAT Gateway for EKS to access the internet
- EKS Cluster deployed in private subnets, configured to use OIDC
- Security Groups for EKS nodes and node groups with necessary port permissions
- IAM Roles and Policies for EKS cluster to assume roles to use AWS resources (eg. ExternalDNS etc.) 
- DynamoDB databases to store data for the items in shop and customers' checkout orders
- ECR repositories to store container images
- Eventbridge to trigger SQS to send messages upon a checkout order
- Lambda function to process checkout order and insert data into DynamoDB 

## GITHUB ACTIONS

<h3>GitHub Actions</h3>
<table border="1">
    <tr>
        <th align="center">Github Action</th>
        <th align="center" width="500">Description</th>
    </tr>
    <tr>
        <td align="center"><code>CI</code></td>
        <td align="center">Autorun during a pull request to main branch, will do a Terraform fmt, TFlint, Terraform Validate and Plan check before merge</td>
    </tr>
    <tr>
        <td align="center"><code>CD</code></td>
        <td align="center">Manual action to create Terraform resources in a specified environment</td>
    </tr>
    <tr>
        <td align="center"><code>terraform-manual destory</code></td>
        <td align="center">Manual action to destory all Terraform resources associated with the chosen environment</td>
    </tr>
</table>

## ENVIRONMENTS

- dev
- uat
- prod

## BRANCHING STRATEGY AND PERMISSIONS

- Trunk-based development style, with each person making commits on their own feature branch then making a pull request to main branch 
- Main branch is protected from any direct pushes and requires at least one other person in the team to approve the changes. 

## DEVELOPER WORKFLOW

1. Clone the repository: git clone https://github.com/Kento555/Capstone-Project-Group2-Infra
2. Create a feature branch: git checkout -b dev/new-feature
3. Push changes and open a pull request to main
4. After receiving 1 approval, the PR is merged to main.
5. Run CD workflow file and choose the environment to create new Terraform resources


