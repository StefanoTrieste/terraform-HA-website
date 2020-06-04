

resource "aws_launch_configuration" "bastion" {
    //preferred AZ
    name                    = "bastion_config"
    image_id                = "${var.server_ami}"
    instance_type           = "t2.micro"
    security_groups         = ["${aws_security_group.bastion.id}"]
    //subnet_id               = "${aws_subnet.public_a.id}"
    user_data               = <<EOT
#!/bin/bash
yum update -y
    EOT
    key_name        = "doingSyd"
}

resource "aws_autoscaling_group" "bastion" {
    name                        = "bastion_ag"
    max_size                    = 1
    min_size                    = 1
    health_check_grace_period   = 300
    health_check_type           = "EC2"
    launch_configuration        = "${aws_launch_configuration.bastion.name}"
    vpc_zone_identifier         = [
        "${aws_subnet.public_a.id}","${aws_subnet.public_b.id}"
    ]


}


//output "Bastion IP Address" {
//    value = "${aws_instance.bastion.public_ip}"
//}