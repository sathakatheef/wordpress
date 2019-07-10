######Definig IAM policy document#######
data "aws_iam_policy_document" "this" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

######IAM_Role (services rolename)#######
resource "aws_iam_role" "this" {
  name               = "service-role"
  path               = "/service-role/"
  assume_role_policy = "${data.aws_iam_policy_document.this.json}"
}

#####IAM_Policy_Attachment (services rolename)#####
resource "aws_iam_role_policy_attachment" "this" {
 #count      = "${var.policy_index}"
  role       = "${aws_iam_role.this.name}"
  policy_arn = ["arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess","arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"]
}

#####IAM_Instance_Profile (services rolename)#######
resource "aws_iam_instance_profile" "this" {
  role  = "${aws_iam_role.this.name}"
  name  = "${aws_iam_role.this.name}"
}
