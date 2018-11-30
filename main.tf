variable "access_key" {}

variable "secret_key" {}

variable "vpc_id" {}

variable "subnet_cidr_block" {}

variable "route_table_id" {}

variable "key_name" {
  default = ""
}

variable "region" {
  default = "us-east-1"
}

variable "server_port" {
  default = "8080"
}

output "private_ip" {
  value = "${aws_instance.instance.private_ip}"
}

terraform {
  required_version = ">= 0.11.7"
}

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "us-east-1"
}

data "template_file" "user_data" {
  template = "${file("${path.module}/server.sh.tpl")}"

  vars {
    server_port = "${var.server_port}"
  }
}

resource "aws_instance" "instance" {
  ami                    = "ami-09479453c5cde9639"
  instance_type          = "t2.nano"
  user_data              = "${data.template_file.user_data.rendered}"
  subnet_id              = "${aws_subnet.instance_a.id}"
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]
  ebs_optimized          = "false"
  key_name               = "${var.key_name}"

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "8"
    delete_on_termination = "true"
  }

  tags {
    Name = "terraform_example_instance"
  }
}

resource "aws_security_group" "instance" {
  name   = "terraform_sg_example_instance"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port   = "${var.server_port}"
    to_port     = "${var.server_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_subnet" "instance_a" {
  vpc_id            = "${var.vpc_id}"
  availability_zone = "${var.region}a"
  cidr_block        = "${var.subnet_cidr_block}"

  tags {
    Name = "subnet_example_instance_a"
  }
}

resource "aws_route_table_association" "instance_a" {
  subnet_id      = "${aws_subnet.instance_a.id}"
  route_table_id = "${var.route_table_id}"
}
