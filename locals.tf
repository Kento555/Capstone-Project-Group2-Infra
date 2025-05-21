locals {
  env         = "ce-grp-2-dev"
  region      = "us-east-1"
  zone1       = "us-east-1a"
  zone2       = "us-east-1b"
  eks_name    = "ce-grp-2-eks"
  eks_version = "1.32"
  services = [
    "adservice", "cartservice", "checkoutservice", "currencyservice",
    "emailservice", "frontend", "paymentservice", "productcatalogservice",
    "recommendationservice", "redis", "shippingservice", "loadgenerator"
  ]
}