

// security group for the bastion host
resource "aws_security_group" "bastion" {
    name = "ssh in"
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
