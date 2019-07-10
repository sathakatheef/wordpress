## Required azs in lookup function and to create a subnets in across azs
variable "azs" {
  type        = "map"
  description = "Configuring zone for region"

  default = {
    ap-southeast-1 = ""
    ap-southeast-2 = "ap-southeast-2a,ap-southeast-2b" ## This is what we are using in current aws infrastructure - a,b zone
    ap-northeast-1 = ""
    ap-northeast-2 = ""
    ap-south-1     = ""
    sa-east-1      = ""
    eu-west-2      = ""
    eu-central-1   = ""
    eu-west-1      = ""
    ca-central-1   = ""
    us-west-2      = ""
    us-west-1      = ""
    us-east-2      = ""
    us-east-1      = ""
  }
}

########## VPC ##########

resource "aws_vpc" "this" {
        cidr_block = "${var.cidr_block}"
        instance_tenancy = "default"
        enable_dns_hostnames = "true"
        enable_dns_support = "true"
        enable_classiclink = "false"

        tags = {
                                                Name = "${var.environment}-${var.product}-vpc"
                                                Environment = "${var.environment}"
                                                Terraform = "true"
                                 }

        lifecycle { create_before_destroy = true }
}

########## DHCP-OPTIONS ##########

resource "aws_vpc_dhcp_options" "this" {
  domain_name          = "aws.1-stop.biz"
  domain_name_servers  = ["AmazonProvidedDNS"]
#  ntp_servers          = ["",""]
#  netbios_name_servers = ["",""]
#  netbios_node_type    = ""
  tags = {
                                                Name = "dopts-${var.environment}-${var.product}"
                                                Environment = "${var.environment}"
                                                Terraform = "true"
         }

        lifecycle { create_before_destroy = true }
}

########## DHCP-OPTIONS-ASSOCIATION ##########

resource "aws_vpc_dhcp_options_association" "this" {
  vpc_id          = "${aws_vpc.this.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.this.id}"

        depends_on = ["aws_vpc.this"]
}

resource "aws_default_route_table" "this" {
  default_route_table_id = "${aws_vpc.this.default_route_table_id}"
  propagating_vgws = ["${aws_vpn_gateway.this.id}"]
  tags = {
                                                Name = "rtb-${var.environment}-${var.product}"
                                                Environment = "${var.environment}"
                                                Terraform = "true"
         }

        depends_on = ["aws_vpc.this"]
        lifecycle { create_before_destroy = true }
}

resource "aws_default_network_acl" "this" {
  default_network_acl_id = "${aws_vpc.this.default_network_acl_id}"

        ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  tags = {
                                                Name = "nacl-${var.environment}-${var.product}"
                                                Environment = "${var.environment}"
                                                Terraform = "true"
         }

#  subnet_ids = ["${aws_subnet.this-private-sn.*.id}","${aws_subnet.this-pub-sn.*.id}"]
  subnet_ids = ["${aws_subnet.this-pub-sn.*.id}"]
        depends_on = ["aws_vpc.this"]
        lifecycle { create_before_destroy = true }
}

resource "aws_network_acl" "this" {
        count = "${length(var.product_roles)}"
        vpc_id = "${aws_vpc.this.id}"

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  tags = {
                                                Name = "nacl-${var.environment}-${var.product}-${var.product_roles[count.index  % length(var.product_roles)]}"
                                                Environment = "${var.environment}"
                                                Terraform = "true"
         }

  #subnet_ids = ["${aws_subnet.this-private-sn.*.id}"]
  subnet_ids = ["${data.aws_subnet_ids.this-private-subnet.*.ids[count.index]}"]
        depends_on = ["aws_vpc.this","aws_subnet.this-private-sn","data.aws_subnet_ids.this-private-subnet"]
        lifecycle { create_before_destroy = true }
}

data "aws_subnet_ids" "this-private-subnet" {
  count = "${length(var.product_roles)}"
  vpc_id = "${aws_vpc.this.id}"
  tags {
    Role = "${var.product_roles[count.index]}"
  }
        depends_on = ["aws_subnet.this-private-sn"]
}

########## PUBLIC (NAT) SUBNETS ##########

resource "aws_subnet" "this-pub-sn" {
  vpc_id     = "${aws_vpc.this.id}"
  count  = "${length(split(",", lookup(var.azs, var.region)))}"
  availability_zone = "${element(split(",", lookup(var.azs, var.region)), count.index)}"
  cidr_block = "${cidrsubnet(var.cidr_block, 8, count.index)}"
  map_public_ip_on_launch = "true" ## This is the only difference between public and private subnets

  tags = {
            Name = "pub-sn-${var.environment}-${substr(element(split(",", lookup(var.azs, var.region)),count.index),-1,1)}"
            Environment = "${var.environment}"
            Terraform = "true"
                                                Tier = "Public"
                           }

        lifecycle { create_before_destroy = true }
        depends_on = ["aws_vpc.this","aws_internet_gateway.this"]
}


########## PRIVATE SUBNETS ##########

resource "aws_subnet" "this-private-sn" {
  vpc_id     = "${aws_vpc.this.id}"
  count = "${length(split(",", lookup(var.azs, var.region))) * length(var.product_roles)}"      ## This will set count value to  no of azs in defiend region variable multiply by "X", so we can have equal subnets across zones.
  availability_zone = "${element(split(",", lookup(var.azs, var.region)), count.index)}"        ## This will set subnets across the azs
#  count        = "${var.subnets["web_subnets"] + var.subnets["app_subnets"] + var.subnets["db_subnets"]}" ## Specifying count of subnets per product role
#  availability_zone = "${element(split(",", lookup(var.azs, var.region)), count.index)}"       ## This will set subnets across the azs - require fixing math formula for product based subnetting
  cidr_block = "${cidrsubnet(var.cidr_block, 8, count.index + 2)}"      ## Creating subnet with prefix = vpc-cidr prefix + 4 and count.index = netmum
  map_public_ip_on_launch = "${var.map_public_ip_on_launch}"

  tags = {
            Name        = "priv-sn-${var.environment}-${var.product}-${var.product_roles[count.index % length(var.product_roles)]}-${substr(element(split(",", lookup(var.azs, var.region)),count.index),-1,-1)}" #This logic works only with odd number of product roles
        #   Name        = "priv-sn-${var.environment}-${var.product_roles[count.index % 8]}-${substr(element(split(",", lookup(var.azs, var.region)),count.index),-1,-1)}"
        #   Name        = "priv-sn-${var.environment}-${var.product_roles[count.index % length(var.product_roles)]}-${substr(var.region[var.azs[count.index]],-1,-1)}"
            Environment = "${var.environment}"
            Role        = "${var.product_roles[count.index  % length(var.product_roles)]}"
            Terraform   = "true"
            Tier        = "Private"
         }

        lifecycle { create_before_destroy = true }
        depends_on = ["aws_vpc.this"]
}

########## VPN GATEWAY  ##########

resource "aws_vpn_gateway" "this" {
  vpc_id = "${aws_vpc.this.id}"

  tags = {
                                                Name = "vgw-${var.environment}-${var.product}"
                                                Environment = "${var.environment}"
                                                Terraform = "true"
                                 }

        lifecycle { create_before_destroy = true }
  depends_on = ["aws_vpc.this"]
}

########## INTERNET GATEWAY  ##########

resource "aws_internet_gateway" "this" {
  vpc_id = "${aws_vpc.this.id}"

  tags =  {
                                                        Name = "igw-${var.environment}-${var.product}"
                                                        Environment = "${var.environment}"
                                                        Terraform = "true"
                                  }

        lifecycle { create_before_destroy = true }
  depends_on = ["aws_vpc.this"]
}

######### NAT GATWAYS ##########

resource "aws_nat_gateway" "this" {
  count  = "${length(split(",", lookup(var.azs, var.region)))}" ## Create NAT GW in each acz, count should be no of public subnets
# allocation_id = "${element(aws_eip.this.*.id,count.index)}" #### The Allocation ID of the Elastic IP address for the gateway.
# allocation_id = "${element(aws_eip_association.this.*.id,count.index)}" #### The Allocation ID of the Elastic IP address for the gateway.
  allocation_id = "${element(aws_eip.this.*.id,count.index)}" #### The Allocation ID of the Elastic IP address for the gateway.
  subnet_id     = "${element(aws_subnet.this-pub-sn.*.id,count.index)}"

  tags = {
                                                Name = "ngw-${var.environment}-${var.product}-${substr(element(split(",", lookup(var.azs, var.region)),count.index),-1,1)}"
                                                Environment = "${var.environment}"
                                                Terraform = "true"
                                                Tier = "Public"
                                 }
        lifecycle { create_before_destroy = true }
        depends_on = ["aws_subnet.this-pub-sn","aws_internet_gateway.this","aws_eip.this"]
}

######## EIPs ##########

resource "aws_eip" "this" {
  count  = "${length(split(",", lookup(var.azs, var.region)))}" # count should be number of nat gateways, if no eip assoiciatoin and if all eip is different
        vpc = true

  tags = {
            Name = "eip-ngw-${var.environment}-${var.product}-${substr(element(split(",", lookup(var.azs, var.region)),count.index),-1,1)}"
            Environment = "${var.environment}"
            Terraform = "true"
         }

        lifecycle { create_before_destroy = "true" }
        depends_on = ["aws_internet_gateway.this"]
}

########## ROUTE TABLES ##########

resource "aws_route_table" "this-pub" {
#  count = "${length(aws_subnet.this-pub-sn.*.id)}"
  count = "${length(split(",", lookup(var.azs, var.region)))}"
  vpc_id = "${aws_vpc.this.id}"

        depends_on = ["aws_subnet.this-pub-sn"]
  tags {
    Name = "rtb-pub-${var.environment}-${var.product}-${substr(element(split(",", lookup(var.azs, var.region)),count.index),-1,1)}"
    Environment = "${var.environment}"
    Terraform = "true"
  }
}

resource "aws_route_table_association" "this-pub" {
#       count  = "${length(aws_route_table.this-pub.*.id)}"
  count = "${length(split(",", lookup(var.azs, var.region)))}"
        subnet_id = "${element(aws_subnet.this-pub-sn.*.id,count.index)}"
        route_table_id = "${element(aws_route_table.this-pub.*.id,count.index)}"
        depends_on = ["aws_route_table.this-pub"]
 }

resource "aws_route" "this" {
  route_table_id = "${aws_default_route_table.this.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = "${aws_nat_gateway.this.0.id}" # If there is a multiple nat gateway, we should only use instead of all, to get single public ip to route all traffic
}

resource "aws_route" "this-pub" {
#  count = "${length(aws_route_table.this-pub.*.id)}"
  count = "${length(split(",", lookup(var.azs, var.region)))}"
  route_table_id = "${element(aws_route_table.this-pub.*.id,count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.this.id}"
}

######## Adopt Default Security Group ###########

resource "aws_default_security_group" "this" {
  vpc_id = "${aws_vpc.this.id}"

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
