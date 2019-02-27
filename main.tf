provider "aws" {
  region = "eu-west-1"
}

module "app" {
  source = "modules/app_tier"
  vpc_id = "${aws_vpc.vpc.id}"
  app_name = "${var.app_name}"
  app_ami_id = "${var.app_ami_id}"
  route_table_id = "${aws_route_table.route_table.id}"
  db_instance_private_ip = "${module.db.instance_private_ip}"
}

module "db" {
  source = "modules/db_tier"
  vpc_id = "${aws_vpc.vpc.id}"
  db_name = "${var.db_name}"
  db_ami_id = "${var.db_ami_id}"
  route_table_id = "${aws_route_table.route_table.id}"
  app_security_group_id = "${module.app.security_group_id}"
}

# VPC

resource "aws_vpc" "vpc" {
  cidr_block = "11.0.0.0/16"
  tags {
    Name = "aidan-tf-vpc"
  }
}

# Internet Gateway

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name = "aidan-tf-ig"
  }
}

# Route Table

resource "aws_route_table" "route_table" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.internet_gateway.id}"
  }

  tags {
    Name = "aidan-tf-route-table"
  }

}
