# Instance

resource "aws_instance" "logstash_instance" {
  ami = "${var.logstash_ami_id}"
  private_ip = "12.0.2.10"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.logstash_subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.logstash_sg.id}"]
  user_data = "${data.template_file.logstash_init.rendered}"
  tags {
    Name = "${var.logstash_name}"
  }
}

# NACL

resource "aws_network_acl" "logstash_nacl" {
  vpc_id = "${var.vpc_id2}"
  subnet_ids = ["${aws_subnet.logstash_subnet.id}"]

  ingress {
    rule_no = 100
    action = "allow"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_block = "62.249.208.122/32"
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
    from_port = 5044
    to_port = 5044
    protocol = "tcp"
    cidr_block = "12.0.1.0/24"
  }

  ingress {
    rule_no = 130
    action = "allow"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_block = "0.0.0.0/0"
  }

  egress {
    rule_no = 100
    action = "allow"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_block = "0.0.0.0/0"
  }

  tags = {
    Name = "${var.logstash_name}-nacl"
  }
}

# Subnet

resource "aws_subnet" "logstash_subnet" {
  vpc_id = "${var.vpc_id2}"
  cidr_block = "12.0.2.0/24"
  availability_zone = "eu-west-1a"
  map_public_ip_on_launch = "true"
  tags {
    Name = "${var.logstash_name}-subnet"
  }
}

# Security Group

resource "aws_security_group" "logstash_sg" {
  name = "${var.logstash_name}-group"
  vpc_id = "${var.vpc_id2}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["62.249.208.122/32"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5044
    to_port     = 5044
    protocol    = "tcp"
    cidr_blocks = ["12.0.1.0/24"]
  }

  ingress {
    from_port   = 1024
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.logstash_name}-sg"
  }

}

# Route Table Association

resource "aws_route_table_association" "logstash_association" {
  subnet_id = "${aws_subnet.logstash_subnet.id}"
  route_table_id = "${var.route_table_id2}"
}

# Templates

data "template_file" "logstash_init" {
  template = "${file("scripts/logstash/init.sh.tpl")}"
}

# AMI

data "aws_ami" "logstash_ami" {
  most_recent = true
  owners = ["self"]

  filter {
    name = "image-id"
    values = ["${var.logstash_ami_id}"]
  }
}
