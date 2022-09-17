locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  customer_vars    = read_terragrunt_config(find_in_parent_folders("customer.hcl"))
  customer_name    = local.customer_vars.locals.customer_name
  environment_name = local.environment_vars.locals.environment
  aws_account_id   = local.account_vars.locals.aws_account_id
  aws_region       = local.region_vars.locals.aws_region
  eks_cluster      = "demo-cluster"
}


terraform {
  source = "git@github.com:maheshglm/aws-infra.git//modules/vpc/v3.14.2"
}

dependency "unique_id" {
  config_path = "../unique_id"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  customer    = local.customer_name
  environment = local.environment_name
  unique_id   = dependency.unique_id.outputs.id

  cidr             = "10.0.0.0/16"
  private_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets   = ["10.0.3.0/24", "10.0.4.0/24"]
  database_subnets = ["10.0.5.0/24", "10.0.6.0/24"]

  enable_nat_gateway   = true
  enable_vpn_gateway   = true
  enable_dns_support   = true
  enable_dns_hostnames = true
  single_nat_gateway   = true

  private_subnet_tags = {
    "Subnet"                                     = "private",
    "kubernetes.io/role/internal-elb"            = "1",
    "kubernetes.io/cluster/${local.eks_cluster}" = "shared"
  }

  public_subnet_tags = {
    "Subnet"                                     = "public",
    "kubernetes.io/role/internal-elb"            = "1",
    "kubernetes.io/cluster/${local.eks_cluster}" = "shared"
  }
}