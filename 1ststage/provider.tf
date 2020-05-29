provider "aws" {
  	//access_key = "your_key_here"
  	//secret_key = "your_secret_here"
	//alternatively set up the AWS console and use "aws configure" to set up access
  region = "ap-southeast-2"
	//if changing the region ensure the AMI id are updated accordingly. AMI are regional.
}
