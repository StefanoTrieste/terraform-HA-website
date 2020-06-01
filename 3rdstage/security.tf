

// security group for the bastion host
// note that security groups are peculiar to the selected custom VPC
resource "aws_security_group" "bastion" {
    name = "allow ssh in"
    vpc_id = "${aws_vpc.my_vpc.id}"
    ingress{
        from_port = 22
        to_port = 22
        protocol = "TCP"
        cidr_blocks=["0.0.0.0/0"] //restrict this for security in prod. 0/0 only for test.
    }
    egress {
        from_port = 0   //
        to_port = 0     //
        protocol = "-1" //allow all outbound traffic
        cidr_blocks = ["0.0.0.0/0"]
    }
}
// security group ec2 used by the ec2 instance running the webserver
resource "aws_security_group" "ec2" {
    name = "http and ssh in for ec2"
    vpc_id = "${aws_vpc.my_vpc.id}"
    ingress{
        from_port = 80
        to_port = 80
        protocol = "TCP"
        cidr_blocks=["0.0.0.0/0"]
    }
    ingress{
        from_port = 22
        to_port = 22
        protocol = "TCP"
        cidr_blocks=["0.0.0.0/0"] 
    }
    egress {
        from_port = 0   //
        to_port = 0     //
        protocol = "-1" //allow all outbound traffic
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "alb" {
    name = "http and ssh in for alb"
    vpc_id = "${aws_vpc.my_vpc.id}"
    ingress{
        from_port = 80
        to_port = 80
        protocol = "TCP"
        cidr_blocks=["0.0.0.0/0"]
    }
    ingress{
        from_port = 22
        to_port = 22
        protocol = "TCP"
        cidr_blocks=["${var.allowed_ip}"] 
    }
    egress {
        from_port = 0   //
        to_port = 0     //
        protocol = "-1" //allow all outbound traffic
        cidr_blocks = ["0.0.0.0/0"]
    }
}
// security group for the RDS database, so that the EC2 clients are allowed to connect.
resource "aws_security_group" "clients" {
    name = "EC2 connections"
    vpc_id = "${aws_vpc.my_vpc.id}"
    ingress{
        from_port = 3306
        to_port = 3306
        protocol = "TCP"
        security_groups = ["${aws_security_group.ec2.id}"]
    }
    egress {
        from_port = 0   //
        to_port = 0     //
        protocol = "-1" //allow all outbound traffic
        cidr_blocks = ["0.0.0.0/0"]
    }
}
// role for EC2 instances to be able to read-only from S3 config file(s) - this is global
// IAM resources: role, instance profile and role policy, see below
resource "aws_iam_role" "EC2_assume_role" {
  name = "EC2_assume_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "EC2_profile" {
  name = "EC2_profile"
  role = "${aws_iam_role.EC2_assume_role.name}"
}

resource "aws_iam_role_policy" "reads_S3_policy" {
  name = "reads_S3_policy"
  role = "${aws_iam_role.EC2_assume_role.id}"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:List*"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}
