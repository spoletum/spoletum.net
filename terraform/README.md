# Terraform

The terraform folder contains the terraform code to deploy the infrastructure for the project.

## Post-execution tasks

In other for the environment to work, it is necessary that you deploy a ClusterSecretStore resource in the cluster. This resource is used to store the secrets that the application needs to run.

Example:

```yaml
apiVersion: external-secrets.io/v1alpha1
kind: ClusterSecretStore
metadata:
  name: aws-secret-store
spec:
    provider: aws
    parameters:
        region: eu-south-2
        accessKeyID: <access-key-id>
        secretAccessKey: <secret-access-key>
```

The accessKeyID and secretAccessKey are the credentials of an IAM user with the necessary permissions to access the secrets in the AWS Secrets Manager.
