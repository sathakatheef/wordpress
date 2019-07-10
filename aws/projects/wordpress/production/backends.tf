terraform {
  backend "s3" {
    bucket  = "wordpress-bucket"
    key     = "wordpress-prod.tfstate"
    region  = "ap-southeast-2"
    profile = "my-test-account"
  }
}
