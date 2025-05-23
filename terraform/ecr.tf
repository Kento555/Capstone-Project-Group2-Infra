resource "aws_ecr_repository" "services" {
  for_each = toset(var.microservices)
  name     = "${var.name_prefix}-${var.ecr_namespace}/${each.value}-${var.env}"
}