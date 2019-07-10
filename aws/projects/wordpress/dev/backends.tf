terraform {
  backend "s3" {
    bucket  = "wordpress-bucket"
    key     = "wordpress-dev.tfstate"
    region  = "ap-southeast-2"
    profile = "my-test-account"
  }
}
