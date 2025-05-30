resource "aws_ecr_repository" "services" {
  for_each = toset(var.microservices)
  name     = "${var.name_prefix}/${var.env}/${each.value}"
}
