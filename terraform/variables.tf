###########################################################
######                  Variables                    ######
###########################################################
variable "name_prefix" {
  description = "Prefix for all resources"
  type        = string
  default     = "ce-grp-2" # Group Number
}

variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "env" {
  description = "Environment"
  type        = string
  default     = "dev"
}

variable "ecr_namespace" {
  type    = string
  default = "ecr"
}

variable "microservices" {
  type = list(string)
  default = ["adservice",
    "cartservice",
    "checkoutservice",
    "currencyservice",
    "emailservice",
    "frontend",
    "paymentservice",
    "productcatalogservice",
    "recommendationservice",
    "shippingservice",
    "shoppingassistantservice",
  "loadgenerator"]
}
