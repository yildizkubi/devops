terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.40.0"
    }

    github = {
      source = "integrations/github"
      version = "6.1.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}


provider "github" {
  # Configuration options
  token = var.git-token
}

variable "git-token" {
    default = "ghp_JJttMGhpwRsT4HfhWDkCD0xxxxxxxxxxxx"
}

variable "git-user-name" {
    default = "davidclarusway"
}


resource "github_repository" "myrepo" {
    name = "bookstore-api-app"
    visibility = "private"
    auto_init = true  
}

resource "github_branch_default" "main" {
    branch = "main"
    repository = github_repository.myrepo.name
  
}

variable "files"{
    default = ["docker-compose.yml","Dockerfile","requirements.txt","bookstore-api.py"]

}

resource "github_repository_file" "app-files" {
    for_each = toset(var.files)
    content = file(each.value)
    file = each.value
    repository = github_repository.myrepo.name
    branch = "main"
    commit_message = "managed by terraform"
    overwrite_on_create = true  
}

variable "key-name" {
    default = "davidskey"  
}

resource "aws_security_group" "tf-docker-sg" {
  name = "docker-sec-gr-203-07-tr"
  tags = {
    Name = "docker-sec-group-203"
  }
  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    protocol    = -1
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "tf-docker-ec2" {
    ami = "ami-0e731c8a588258d0d"
    instance_type = "t2.micro"
    key_name = var.key-name
    vpc_security_group_ids = [aws_security_group.tf-docker-sg.id]
    tags = {
      Name = "Web Server of Bookstore"
    }

    user_data = templatefile("user-data.sh", {user-data-git-token = var.git-token, user-data-git-user-name = var.git-user-name})
    depends_on = [ github_repository.myrepo, github_repository_file.app-files ]
}


output "website" {
    value = "http://${aws_instance.tf-docker-ec2.public_ip}"
}