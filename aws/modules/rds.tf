resource "aws_rds_cluster" "aurora" {
  count = "${length(var.databases)}"

  cluster_identifier      = "${var.environment == "dev" ? ${var.environment}-${element(var.product,count.index)}-${element(var.purpose,count.index)}-aurora-rds : prod-${element(var.product,count.index)}-${element(var.purpose,count.index)}-aurora-rds"
  availability_zones      = ["${lookup(aws_subnet.this-private-sn.subnet_private_ids, element(var.db_product_roles1, count.index))}","${lookup(aws_subnet.this-private-sn.subnte_private_ids, element(var.db_product_roles2, count.index))}"]             ##########Private_subnets
  vpc_security_group_ids  = ["${aws_default_security_group.this.id}", "${aws_security_group.this.id}"]
  engine		  = "${var.engine}"
  database_name           = "${var.db_name}"
  master_username         = "${var.username}"
  master_password         = "${var.password}"
  port			  = "${var.port}"
  backup_retention_period = 5
  preferred_backup_window = "${var.db_backup_window}"
  skip_final_snapshot     = true
  apply_immediately       = true

  engine_mode = "serverless"

  scaling_configuration {
    auto_pause               = true
    max_capacity             = "${element(var.max_capacity,count.index)}"
    min_capacity             = "${element(var.min_capacity,count.index)}"
    seconds_until_auto_pause = 300
  }

  tags = {
    Name              = "${var.environment == "dev" ? ${var.environment}-${element(var.product,count.index)}-${element(var.purpose,count.index)}-aurora-rds : prod-${element(var.product,count.index)}-${element(var.purpose,count.index)}-aurora-rds"
    environment       = "${var.environment == "dev" ? var.environment : "prod"}"
    product           = "${var.product}"
    product_component = "db"
  }
}
