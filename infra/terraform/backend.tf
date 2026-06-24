terraform {
  backend "s3" {
    bucket         = "capstone-phoenix-tfstate-808999"
    key            = "capstone/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "capstone-phoenix-tf-lock"
    encrypt        = true
  }
}
