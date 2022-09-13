locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  customer_vars    = read_terragrunt_config(find_in_parent_folders("customer.hcl"))

  customer_name    = local.customer_vars.locals.customer_name
  environment_name = local.environment_vars.locals.environment
  aws_account_id   = local.account_vars.locals.aws_account_id
  aws_region       = local.region_vars.locals.aws_region

  main_domain_zone_id = local.account_vars.locals.main_domain_zone_id
}

terraform {
  source = "git@github.com:maheshglm/aws-infra.git//modules/dns_record/v1.0.0?ref=main"
}

include {
  path = find_in_parent_folders()
}

dependency "unique_id" {
  config_path = "../unique_id"
}

dependency "blue" {
  config_path = "../wordpress_blue/lb"
}

dependency "green" {
  config_path = "../wordpress_green/lb"
}

inputs = {
  zone_id = local.main_domain_zone_id
  name    = "wordpress-dev.letsdevops.link"
  type    = "CNAME"
  ttl     = 60
  records = [dependency.green.outputs.lb_dns_name]
}
