## Create S3 Buckets for Loki

# resource "aws_s3_bucket" "chunks" {
#   bucket        = "${var.name_prefix}-loki-chunks-${var.env}"
#   force_destroy = true
# }

# resource "aws_s3_bucket" "ruler" {
#   bucket        = "${var.name_prefix}-loki-ruler-${var.env}"
#   force_destroy = true
# }