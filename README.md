# Introduction
This project contains code to deploy a simple web application.
The application includes a web server and a database, as well
as the infrastructure to connect the two together and monitor
them.

The server will be deployed via the Amazon Elastic Container
Service, or ECS for short. This is a compute service from AWS
that allows you to deploy your code as a container from a
Docker image and manage it that way.

The choice of database is the Amazon DynamoDB.

# IMPORTANT NOTE
I got the project to work on AWS using the web interface, but
I did not have enough time to test the whole thing with
terraform apply unfortunately. So the terraform code needs some
tweaks here and there, and it would work if I had a bit more time.

The only file that I did not test at all not even in the web
interface is the monitoring.tf file. I simply did not have the
time to do it.

# Deploying the project on AWS
## Pre-requisites
You must first install the following tools:
- Terraform
- AWS CLI tool
- Docker

## Deployment
### Connecting Terraform and AWS
First, go to your AWS account and create a service account for
Terraform with the appropriate permissions. This service account
will be used by Terraform to deploy resources on the cloud.
When granting permissions to any account, we should always follow
the least privelege principle. But for the sake of simplicity, we
can just grant it admin permissions for now.

Once you've created a service account, generate an access token
for it. Next, set the following variables in you CLI tool where
Terraform is installed:
```
export AWS_ACCESS_KEY_ID=<SECRET_KEY_ID>
export AWS_SECRET_ACCESS_KEY=<SECRET_KEY_VALUE>
```
Once you've done this, Terraform should be able to connect to
AWS and manage cloud resources there.

Run the following command to verify the connection
```
terraform plan
```

### Preparing the Docker image
Run the following command to build the Docker image
```
docker build -t webapp .
```

Run the following command to deploy the image registry into AWS
```
terraform apply -target=aws_ecr_repository.webapp
```

Run the following commands to push your docker image to the registry,
but first make sure to substitute the variable names with real values:
```
aws ecr get-login-password --region <your-region> | docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.<your-region>.amazonaws.com
docker tag webapp:latest <aws_account_id>.dkr.ecr.<your-region>.amazonaws.com/webapp:latest
docker push <aws_account_id>.dkr.ecr.<your-region>.amazonaws.com/my-app-repo:latest
```

You should now have the docker image of your application on the cloud.

### Deploying the application
To deploy the application, run the following command:
```
terraform apply
```

and that's it. There should now be a server running in the cloud that
is connected to a database in a VPC. The server has a public IP you
can send GET requests to on port 8080.

# Things I would change if I had more time
- The hardcoding of some values when they should be defined as variables
- The usage of tokens/passwords in an insecure way
- The security settings of some of the resources
- The linting of the code
- The packaging of the code
- The handling of packages/dependencies versions
- The naming of some of the resources

# Things I learned while working on this exercise
- AWS services and tools including EC2, ECS, DocumentDB, AWS CLI,
  DynamoDB, AWS IAM, VPCs, and all the other networking components.
  I have never used AWS before this exercise. I have also never had
  to build the infrastructure to run my code on the cloud before,
  nor have I had to provision network setup to this extent.
- How to use Terraform locally and how to use its CLI/commands.
  I've never needed to do this before because it's normally managed
  via pipelines.
