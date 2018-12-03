# Terraform 101

## Configuration

**Create a .tfvars file (terraform.tfvars) with the following content:**
```
vpc_id = "<my-vpc-id>"
route_table_id = "<my-route-table-id>"
key_name = "<my-pem-filename>"
access_key = "<my-access-key>"
secret_key = "<my-secret-key>"
```

## Display an execution plan

```
terraform -var-file=terraform.tfvars plan
```

## Apply changes

```
terraform -var-file=terraform.tfvars apply
```