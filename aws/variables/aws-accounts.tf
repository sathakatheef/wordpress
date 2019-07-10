## List of AWS accounts
variable "accounts" {
  type        = "map"
  description = "Setting up AWS account's profile"

  default =
  {
    test = "my-test-account"
  }
}
