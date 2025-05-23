resource "aws_ecr_repository" "services" {
  for_each             = toset(var.microservices)
  name                 = "${var.name_prefix}-${var.ecr_namespace}/${each.value}-${var.env}"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = false # Scanning will be done with snyk.
  }
}