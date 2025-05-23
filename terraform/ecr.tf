###########################################################
######                    ECR                        ######
###########################################################
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

variable "ecr_namespace" {
  type    = string
  default = "ce-grp-2"
}

resource "aws_ecr_repository" "services" {
  for_each             = toset(var.microservices)
  name                 = "${var.ecr_namespace}/${each.value}"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = false # Scanning will be done with snyk.
  }
}
