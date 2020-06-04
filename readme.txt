# terraform-HA-website

How to create a highly available website with Terraform scripts, using AWS resources

Study: Building a website based on Wordpress, scalable and with high availability.

Requirements and assumptions:
a) The website is based on Wordpress and RDS/MySql
b) The type of application is 90% read / 10% write (i.e. blogging website)
c) Failure of an entire AZ should be tolerated, with an estimated availability of 99.9%
d) Autoscaling would be triggered by CPU usage of current instances or AZ failure

Project development stages:
1) Basic diagram with network infrastructure layout
2) Adding Bastion host with autoscaling group to provide for AZ failure
3) Adding writer nodes with autoscaling for writer node, and Multi-AZ RDS instance, to provide automatic recovery upon AZ failure
4) Adding read replicas for each AZ, and read only nodes with autoscaling group and load balancer

Each stage is accompanied with a schematics diagram, and a Terraform set of scripts to generate the infrastructure up to that stage.
