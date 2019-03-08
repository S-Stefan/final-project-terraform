# Instance

resource "aws_instance" "kibana_instance" {
  ami = "${var.kibana_ami_id}"
  private_ip = "12.0.4.10"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  subnet_id = "${aws_subnet.kibana_subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.kibana_sg.id}"]
  user_data = "${data.template_file.kibana_init.rendered}"
  tags {
    Name = "${var.kibana_name}"
  }
}

# NACL

resource "aws_network_acl" "kibana_nacl" {
  vpc_id = "${var.vpc_id2}"
  subnet_ids = ["${aws_subnet.kibana_subnet.id}"]

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
    from_port = 5601
    to_port = 5601
    protocol = "tcp"
    cidr_block = "12.0.3.0/24"
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
    Name = "${var.kibana_name}-nacl"
  }
}

# Subnet

resource "aws_subnet" "kibana_subnet" {
  vpc_id = "${var.vpc_id2}"
  cidr_block = "12.0.4.0/24"
  availability_zone = "eu-west-1a"
  map_public_ip_on_launch = "true"
  tags {
    Name = "${var.kibana_name}-subnet"
  }
}

# Security Group

resource "aws_security_group" "kibana_sg" {
  name = "${var.kibana_name}-group"
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
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    cidr_blocks = ["12.0.3.0/24"]
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
    Name = "${var.kibana_name}-sg"
  }

}

# Route Table Association

resource "aws_route_table_association" "kibana_association" {
  subnet_id = "${aws_subnet.kibana_subnet.id}"
  route_table_id = "${var.route_table_id2}"
}

# Templates

data "template_file" "kibana_init" {
  template = "${file("scripts/kibana/init.sh.tpl")}"
}

# AMI

data "aws_ami" "kibana_ami" {
  most_recent = true
  owners = ["self"]

  filter {
    name = "image-id"
    values = ["${var.kibana_ami_id}"]
  }
}
