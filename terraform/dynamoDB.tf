resource "aws_dynamodb_table" "product_catalog_table" {
  name         = "${var.name_prefix}-product-catalog-${var.env}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name = "${var.name_prefix}-product-catalog-${var.env}"
  }
}

resource "aws_dynamodb_table" "product_orders_table" {
  name         = "${var.name_prefix}-product-orders-${var.env}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "order_id"

  attribute {
    name = "order_id"
    type = "S"
  }

  tags = {
    Name = "${var.name_prefix}-product-orders-${var.env}"
  }
}
