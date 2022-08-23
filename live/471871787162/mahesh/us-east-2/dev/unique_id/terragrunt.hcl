locals {
  environment_vars             = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars                 = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars                  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  customer_vars                = read_terragrunt_config(find_in_parent_folders("customer.hcl"))
  customer_name                = local.customer_vars.locals.customer_name
  environment_name             = local.environment_vars.locals.environment
  aws_account_id               = local.account_vars.locals.aws_account_id
  aws_region                   = local.region_vars.locals.aws_region
}


terraform {
  source = "git@github.com:maheshglm/aws-infra.git//modules/unique_id/v1.0.0"
#  extra_arguments "bucket" {
#    commands = get_terraform_commands_that_need_vars()
#    optional_var_files = [
#      find_in_parent_folders("account.tfvars", "ignore"),
#      find_in_parent_folders("region.tfvars", "ignore"),
#      find_in_parent_folders("env.tfvars", "ignore"),
#    ]
#  }
}


include {
  path = find_in_parent_folders()
}

inputs = {}