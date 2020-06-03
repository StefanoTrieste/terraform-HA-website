resource "random_password" "password" {
    length              = 16
    special             = true
    override_special    = "!#$?"
}

  resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = ["${aws_subnet.private_a.id}","${aws_subnet.private_b.id}"] 
  tags = {
    Name = "Main DB subnet group"
  }
}
      
resource "aws_db_instance" "db" {
  identifier              = "hawdb-instance"
  //availability_zone       = "${aws_subnet.private_a.availability_zone}" //if no multi_az
  multi_az                = true
  db_subnet_group_name    = "${aws_db_subnet_group.default.name}"
  allocated_storage       = 20
  storage_type            = "gp2" //SSD storage in EBS
  engine                  = "mysql"
  engine_version          = "5.7.22" //Version that works in Wordpress
  instance_class          = "db.t2.micro" //Free tier
  name                    = "hawdb"
  username                = "hawdb_admin"
  password                = "${random_password.password.result}" //password is never displayed
  parameter_group_name    = "default.mysql5.7"
  skip_final_snapshot     = "true" //Test environment option, make false for production
  vpc_security_group_ids  = ["${aws_security_group.clients.id}"]

}
//  un-comment these lines if you need to check the DB directly
//output "db_instance_address" {
//  value = "${aws_db_instance.db.address}"
//}
//    output "password" {
//  value  = "${aws_db_instance.db.password}"
//}