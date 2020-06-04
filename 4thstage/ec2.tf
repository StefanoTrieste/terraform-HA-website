

resource "aws_launch_configuration" "webserver" {
    name                    = "WP instance"
    image_id                = "${var.server_ami}"
    instance_type           = "t2.micro"
    //availability_zones       = "${aws_subnet.private_a.availability_zone}" 
    security_groups         = ["${aws_security_group.ec2.id}"]
    iam_instance_profile    = "${aws_iam_instance_profile.EC2_profile.name}"
    key_name        = "doingSyd"
    user_data       = <<EOT
#!/bin/bash
yum update -y
yum install httpd php-mysql -y
sudo amazon-linux-extras install php7.4 -y
systemctl enable httpd
systemctl start httpd
cd /var/www/html
echo "healthy" > healthy.html
wget http://wordpress.org/latest.tar.gz
tar -xzvf latest.tar.gz
cp -r wordpress/* /var/www/html
rm -rf wordpress
rm -rf latest.tar.gz
chmod -R 755 wp-content
chown -R apache:apache wp-content
aws s3 cp s3://${aws_s3_bucket.b.bucket}/${aws_s3_bucket_object.wpconfig.key} /var/www/html/wp-config.php
    EOT
}
resource "aws_autoscaling_group" "writer" {
    name                        = "writer_ag"
    max_size                    = 1
    min_size                    = 1
    health_check_grace_period   = 300
    health_check_type           = "EC2"
    launch_configuration        = "${aws_launch_configuration.webserver.name}"
    target_group_arns           = [
        "${aws_lb_target_group.wlb_tg.arn}"
    ]
    vpc_zone_identifier         = [
        "${aws_subnet.private_a.id}","${aws_subnet.private_b.id}"
    ]
}

//writer target group for ALB
resource "aws_lb_target_group" "wlb_tg" {
    name        = "writer-target-group"
    port        = 80
    protocol    = "HTTP"
    target_type = "instance"
    vpc_id      = "${aws_vpc.my_vpc.id}"
    health_check {
        path = "/healthy.html"
    }
}

resource "aws_lb" "wlb" {
    name    = "writer-lb"
    internal    = false
    load_balancer_type  = "application"
    security_groups     = ["${aws_security_group.alb.id}"]
    subnets             = ["${aws_subnet.public_a.id}","${aws_subnet.public_b.id}"]
}

resource "aws_lb_listener" "wlb_l" {
    load_balancer_arn   = "${aws_lb.wlb.arn}"
    port                = 80
    protocol            = "HTTP"
    default_action {
        type                = "forward"
        target_group_arn    = "${aws_lb_target_group.wlb_tg.arn}"
    }
}

resource "aws_lb_listener_rule" "listener_rule" {
    listener_arn    = "${aws_lb_listener.wlb_l.arn}"    
    priority        = 100
    action  {
        type        = "forward"
        target_group_arn = "${aws_lb_target_group.wlb_tg.arn}"
    }
    condition {
        path_pattern {
            values = ["/*"]
        }
    }
}

output "writer ELB Address" {
    value = "${aws_lb.wlb.dns_name}"
}