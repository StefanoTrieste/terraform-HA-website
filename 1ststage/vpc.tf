resource "aws_vpc" "my_vpc" {
  cidr_block       = "10.0.0.0/16"
  
  tags = {
    Name = "vpc_HAW"
  }
}

resource "aws_subnet" "public_a" {
  vpc_id                    = "${aws_vpc.my_vpc.id}"
  cidr_block                ="10.0.240.0/24"
  map_public_ip_on_launch   = true
  availability_zone         = "ap-southeast-2a"
  tags = {
    Name                    = "public_a-10.0.240.0"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                    = "${aws_vpc.my_vpc.id}"
  cidr_block                ="10.0.241.0/24"
  map_public_ip_on_launch   = true
  availability_zone         = "ap-southeast-2b"
  tags = {
    Name                    = "public_b-10.0.241.0"
  }
}

resource "aws_subnet" "private_a" {
  vpc_id                    = "${aws_vpc.my_vpc.id}"
  cidr_block                ="10.0.16.0/20"
  map_public_ip_on_launch   = false
  availability_zone         = "ap-southeast-2a"
  tags = {
    Name                    = "private_a-10.0.16.0"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id                    = "${aws_vpc.my_vpc.id}"
  cidr_block                ="10.0.32.0/20"
  map_public_ip_on_launch   = false
  availability_zone         = "ap-southeast-2b"
  tags = {
    Name                    = "private_b-10.0.32.0"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.my_vpc.id}"

  tags = {
   Name = "Internet_gw"
  }
}

resource "aws_route" "r" {
  //adding a route to the default route table, to the internet gw
  route_table_id  = "${aws_vpc.my_vpc.default_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.gw.id}"
}