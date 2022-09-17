variable "cluster_name" {
  type    = string
  default = "demo-cluster"
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "tags" {
  type = map(any)
}