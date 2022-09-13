locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  customer_vars    = read_terragrunt_config(find_in_parent_folders("customer.hcl"))

  project_vars    = read_terragrunt_config(find_in_parent_folders("project.hcl"))
  project_name     = local.project_vars.locals.project_name

  customer_name    = local.customer_vars.locals.customer_name
  environment_name = local.environment_vars.locals.environment
  aws_account_id   = local.account_vars.locals.aws_account_id
  aws_region       = local.region_vars.locals.aws_region
  name_prefix      = format("%s-%s", local.customer_name, local.environment_name)

}

terraform {
  source = "git@github.com:maheshglm/aws-infra.git//modules/load_balancer/v6.10.0?ref=main"
}

include {
  path = find_in_parent_folders()
}

dependency "unique_id" {
  config_path = "../../unique_id"
}

dependency "vpc" {
  config_path = "../../vpc"
}

dependency "acm" {
  config_path = "../../acm"
}


inputs = {
  lb_type      = "alb"
  project      = local.project_name
  environment  = local.environment_name
  unique_id    = dependency.unique_id.outputs.id
  vpc_id       = dependency.vpc.outputs.vpc_id
  subnets      = dependency.vpc.outputs.public_subnets
  idle_timeout = 300

  custom_security_groups = [
    {
      security_group_name      = "${local.name_prefix}-${local.project_name}-alb-sg"
      security_group_desc      = "Security Group for ${local.project_name} Load balancer group"
      vpc_id                   = dependency.vpc.outputs.vpc_id
      ingress_with_cidr_blocks = [
        { from_port = 443, to_port = 443, protocol = "tcp", description = "Https traffic", cidr_blocks = "0.0.0.0/0" },
        { from_port = 80, to_port = 80, protocol = "tcp", description = "Http traffic", cidr_blocks = "0.0.0.0/0" },
      ]
      egress_with_cidr_blocks  = [
        { from_port = 0, to_port = 0, protocol = "-1", description = "", cidr_blocks = "0.0.0.0/0" },
      ]
    }
  ]

  target_groups = [
    {
      name_prefix      = "wpalb-" //max 6 chars
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      health_check     = {
        matcher = "200,302"
      }
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = dependency.acm.outputs.acm_certificate_arn
      target_group_index = 0
    }
  ]

  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect    = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]
}
