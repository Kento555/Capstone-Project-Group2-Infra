#file: backend.tf

terraform {
  backend "s3" {
    bucket = "sctp-ce9-tfstate"
    key    = "sctp-ce9-capstone.tfstate" # Replace the value of key to <your suggested name>.tfstat   
    region = "us-east-1"
  }
}
