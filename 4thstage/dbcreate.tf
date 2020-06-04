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
  backup_retention_period = 1 //required so that the other read replica instance can be created as such, needs to be between 1 and 35
  identifier              = "hawdb-instance"
  //availability_zone       = "${aws_subnet.private_a.availability_zone}" //pick up AZ from private_a (only if non multi_az)
  multi_az                = true //for a faster test run set this to false
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

resource "aws_db_instance" "readreplica" {
  identifier              = "hawdb-readreplica"
  //availability_zone       = "${aws_subnet.private_b.availability_zone}" //pick up AZ from private_b (only if non multi_az)
  multi_az                = true //for a faster test run set this to false
  replicate_source_db     = "${aws_db_instance.db.id}" //defines read replica and source db
  //db_subnet_group_name    = "${aws_db_subnet_group.default.name}" //not for read replica, not allowed
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