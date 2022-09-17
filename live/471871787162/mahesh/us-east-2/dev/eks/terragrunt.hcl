locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  customer_vars    = read_terragrunt_config(find_in_parent_folders("customer.hcl"))
  customer_name    = local.customer_vars.locals.customer_name
  environment_name = local.environment_vars.locals.environment
  aws_account_id   = local.account_vars.locals.aws_account_id
  aws_region       = local.region_vars.locals.aws_region

}

terraform {
  source = ".//src"
}

dependency "vpc" {
  config_path = "../vpc"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  cluster_name       = "demo-cluster"
  private_subnet_ids = dependency.vpc.outputs.private_subnets
  public_subnet_ids  = dependency.vpc.outputs.public_subnets
  tags               = {
    terraform = true
  }
}