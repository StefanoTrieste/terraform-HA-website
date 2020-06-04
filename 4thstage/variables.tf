variable "server_ami" { //improve this by automatically selecting AMI in region.
    type    = "string"
    default = "ami-0970010f37c4f9c8d" //AMI Amazon Linux 2 x86 64-bit ap-southeast-2
}

variable "allowed_ip" {
    type    ="string"
    default = "1.2.3.4/32" //insert here your IP address, so that you can connect to the website.
}                                 //if you use 0.0.0.0/0 EVERYONE will be able to connect - not recommended
                                  //as the first page is the wordpress configuration.