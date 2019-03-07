# Templates

data "template_file" "db_init" {
  template = "${file("scripts/db/init.sh.tpl")}"
}

# Instance

resource "aws_instance" "db_instance" {
  ami = "${var.db_ami_id}"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.db_subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.db_sg.id}"]
  private_ip = "11.0.14.100"
  user_data = "${data.template_file.db_init.rendered}"
  tags {
    Name = "${var.db_name}"
  }
}

resource "aws_instance" "db_instance_secondary_1" {
  ami = "${var.db_ami_id}"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.db_subnet_secondary_1.id}"
  vpc_security_group_ids = ["${aws_security_group.db_sg.id}"]
  private_ip = "11.0.15.100"
  tags {
    Name = "${var.db_name}-secondary-1"
  }
}

resource "aws_instance" "db_instance_secondary_2" {
  ami = "${var.db_ami_id}"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.db_subnet_secondary_2.id}"
  vpc_security_group_ids = ["${aws_security_group.db_sg.id}"]
  private_ip = "11.0.16.100"
  tags {
    Name = "${var.db_name}-secondary-2"
  }
}

# NACL

resource "aws_network_acl" "db_nacl" {
  vpc_id = "${var.vpc_id}"
  subnet_ids = ["${aws_subnet.db_subnet.id}"]

  ingress {
    rule_no = 100
    action = "allow"
    from_port = 27017
    to_port = 27017
    protocol = "tcp"
    cidr_block = "11.0.0.0/16"
  }

  ingress {
    rule_no = 110
    action = "allow"
    from_port = 1024
    to_port = 65535
    protocol = "tcp"
    cidr_block = "0.0.0.0/0"
  }

  ingress {
    rule_no = 120
    action = "allow"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_block = "0.0.0.0/0"
  }

  egress {
    rule_no = 100
    action = "allow"
    from_port = 27017
    to_port = 27017
    protocol = "tcp"
    cidr_block = "11.0.0.0/16"
  }

  egress {
    rule_no = 110
    action = "allow"
    from_port = 1024
    to_port = 65535
    protocol = "tcp"
    cidr_block = "0.0.0.0/0"
  }

  tags {
    Name = "${var.db_name}-nacl"
  }
}

# Subnet

resource "aws_subnet" "db_subnet" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "11.0.14.0/24"
  availability_zone = "eu-west-1a"
  tags {
    Name = "${var.db_name}-subnet"
  }
}

resource "aws_subnet" "db_subnet_secondary_1" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "11.0.15.0/24"
  availability_zone = "eu-west-1b"
  tags {
    Name = "${var.db_name}-subnet-secondary-1"
  }
}

resource "aws_subnet" "db_subnet_secondary_2" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "11.0.16.0/24"
  availability_zone = "eu-west-1c"
  tags {
    Name = "${var.db_name}-subnet-secondary-2"
  }
}

# Security Group

resource "aws_security_group" "db_sg" {
  name = "${var.db_name}-group"
  vpc_id = "${var.vpc_id}"
  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    security_groups = ["${var.app_security_group_id}"]
  }

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["11.0.0.0/16"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["62.249.208.122/32"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.db_name}-sg"
  }

}

# Route Table Association

resource "aws_route_table_association" "db_association" {
  subnet_id = "${aws_subnet.db_subnet.id}"
  route_table_id = "${var.route_table_id}"
}

resource "aws_route_table_association" "db_association_secondary_1" {
  subnet_id = "${aws_subnet.db_subnet_secondary_1.id}"
  route_table_id = "${var.route_table_id}"
}

resource "aws_route_table_association" "db_association_secondary_2" {
  subnet_id = "${aws_subnet.db_subnet_secondary_2.id}"
  route_table_id = "${var.route_table_id}"
}

# AMI

data "aws_ami" "db_ami" {
  most_recent = true
  owners = ["self"]

  filter {
    name = "image-id"
    values = ["${var.db_ami_id}"]
  }
}
