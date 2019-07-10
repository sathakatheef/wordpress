## TF AWS provider minimum required version
provider "aws" {
  version    = "~> 1.37"
  region = "${var.region["Sydney"]}"
  shared_credentials_file = "$AWS_HOME/credentials"
  profile = "${var.accounts["${var.account_name}"]}"
}

## List of AWS regions
variable "region" {
  type        = "map"
  description = "Setting up regions"

  default =
        {
    Singapore     = "ap-southeast-1"
    Sydney        = "ap-southeast-2"
    Tokyo         = "ap-northeast-1"
    Seoul         = "ap-northeast-2"
    Mumbai        = "ap-south-1"
    Paulo         = "sa-east-1"
    London        = "eu-west-2"
    Frankfurt     = "eu-central-1"
    Ireland       = "eu-west-1"
    Canada        = "ca-central-1"
    Oregon        = "us-west-2"
    N.Californaia = "us-west-1"
    Ohio          = "us-east-2"
    N.Virginia    = "us-east-1"
  }
}

## Availavility zones for each AWS regions
#variable "availability_zone"
#{
#  type = "map"
#  description = "Configuring zone for each region"
#
#  default =
#  {
#    ap-southeast-1 = []
#    ap-southeast-2 = ["ap-southeeast-2a","ap-southeast-2b","ap-southeast-2c"]
#    ap-northeast-1 = []
#    ap-northeast-2 = []
#    ap-south-1     = []
#    sa-east-1      = []
#    eu-west-2      = []
#    eu-central-1   = []
#    eu-west-1      = []
#    ca-central-1   = []
#    us-west-2      = []
#    us-west-1      = []
#    us-east-2      = []
#    us-east-1      = []
#  }
#}
