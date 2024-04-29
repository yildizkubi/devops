//variable "aws_secret_key" {}
//variable "aws_access_key" {}
variable "region" {
  default = "us-east-1"
}
variable "mykey" {
  default = "mykey"
}
variable "tags" {
  default = ["stage", "production"]
}
variable "myami" {
  description = "amazon linux 2023"
  default = "ami-0e731c8a588258d0d"
}
variable "instancetype" {
  default = "t2.micro"
}

variable "secgrname" {
  default = "TomcatServerSecurityGroup"
}
