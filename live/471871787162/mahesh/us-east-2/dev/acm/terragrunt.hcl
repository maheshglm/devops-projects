locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  customer_vars    = read_terragrunt_config(find_in_parent_folders("customer.hcl"))

  aws_account_id   = local.account_vars.locals.aws_account_id
  customer_name    = local.customer_vars.locals.customer_name
  aws_region       = local.region_vars.locals.aws_region
  environment_name = local.environment_vars.locals.environment

  acm_zone_id = local.account_vars.locals.main_domain_zone_id
  acm_name    = local.account_vars.locals.main_domain_zone_name
}

terraform {
  source = "git@github.com:maheshglm/aws-infra.git//modules/acm/v4.0.0"
  extra_arguments "bucket" {
    commands = get_terraform_commands_that_need_vars()
  }
}

include {
  path = find_in_parent_folders()
}

dependency "unique_id" {
  config_path = "../unique_id"
}

inputs = {
  domain_name               = "${local.acm_name}"
  subject_alternative_names = ["*.${local.acm_name}"]
  zone_id                   = local.acm_zone_id
  customer                  = local.customer_name
  environment               = local.environment_name
  unique_id                 = dependency.unique_id.outputs.id
}