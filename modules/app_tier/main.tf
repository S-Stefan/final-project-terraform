# NACL

resource "aws_network_acl" "app_nacl" {
  vpc_id = "${var.vpc_id}"
  subnet_ids = ["${aws_subnet.app_subnet-a.id}", "${aws_subnet.app_subnet-b.id}", "${aws_subnet.app_subnet-c.id}"]

  ingress {
    rule_no = 100
    action = "allow"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_block = "0.0.0.0/0"
  }

  ingress {
    rule_no = 110
    action = "allow"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_block = "62.249.208.122/32"
  }

  ingress {
    rule_no = 120
    action = "allow"
    from_port = 1024
    to_port = 65535
    protocol = "tcp"
    cidr_block = "0.0.0.0/0"
  }

  egress {
    rule_no = 100
    action = "allow"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_block = "0.0.0.0/0"
  }

  egress {
    rule_no = 110
    action = "allow"
    from_port = 27017
    to_port = 27017
    protocol = "tcp"
    cidr_block = "11.0.11.0/24"
  }

  egress {
    rule_no = 120
    action = "allow"
    from_port = 1024
    to_port = 65535
    protocol = "tcp"
    cidr_block = "0.0.0.0/0"
  }

  tags = {
    Name = "${var.app_name}-nacl"
  }
}

# Subnet

resource "aws_subnet" "app_subnet-a" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "11.0.10.0/24"
  availability_zone = "eu-west-1a"
  map_public_ip_on_launch = "true"
  tags {
    Name = "${var.app_name}-subnet-a"
  }
}

resource "aws_subnet" "app_subnet-b" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "11.0.11.0/24"
  availability_zone = "eu-west-1b"
  map_public_ip_on_launch = "true"
  tags {
    Name = "${var.app_name}-subnet-b"
  }
}

resource "aws_subnet" "app_subnet-c" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "11.0.12.0/24"
  availability_zone = "eu-west-1c"
  map_public_ip_on_launch = "true"
  tags {
    Name = "${var.app_name}-subnet-c"
  }
}

# Security Group

resource "aws_security_group" "app_sg" {
  name = "${var.app_name}-group"
  vpc_id = "${var.vpc_id}"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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
    Name = "${var.app_name}-sg"
  }

}

# Route Table Association

resource "aws_route_table_association" "app_association-a" {
  subnet_id = "${aws_subnet.app_subnet-a.id}"
  route_table_id = "${var.route_table_id}"
}

resource "aws_route_table_association" "app_association-b" {
  subnet_id = "${aws_subnet.app_subnet-b.id}"
  route_table_id = "${var.route_table_id}"
}

resource "aws_route_table_association" "app_association-c" {
  subnet_id = "${aws_subnet.app_subnet-c.id}"
  route_table_id = "${var.route_table_id}"
}

# Templates

data "template_file" "app_init" {
  template = "${file("scripts/app/init.sh.tpl")}"
  vars {
    private_ip = "${var.db_instance_private_ip}"
    private_ip_secondary_1 = "${var.db_instance_private_ip_secondary_1}"
    private_ip_secondary_2 = "${var.db_instance_private_ip_secondary_2}"
  }

}

# Load Balancer

resource "aws_lb" "app_load_balancer" {
  name = "${var.app_name}-lb"
  internal = false
  load_balancer_type = "network"
  subnets = ["${aws_subnet.app_subnet-a.id}", "${aws_subnet.app_subnet-b.id}", "${aws_subnet.app_subnet-c.id}"]
}

# Target Group

resource "aws_lb_target_group" "app_target_group" {
  name = "${var.app_name}-tg"
  target_type = "instance"
  vpc_id = "${var.vpc_id}"
  protocol = "TCP"
  port = 80
}

# Load Balancer Listener

resource "aws_lb_listener" "ssh" {
  load_balancer_arn = "${aws_lb.app_load_balancer.arn}"
  port = "80"
  protocol = "TCP"

  default_action {
    type = "forward"
    target_group_arn = "${aws_lb_target_group.app_target_group.arn}"
  }
}

# AMI

data "aws_ami" "app_ami" {
  most_recent = true
  owners = ["self"]

  filter {
    name = "image-id"
    values = ["${var.app_ami_id}"]
  }
}

# Launch Configuration

resource "aws_launch_configuration" "app_launch_conf" {
  name = "${var.app_name}-launch-conf"
  image_id = "${data.aws_ami.app_ami.id}"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  security_groups = ["${aws_security_group.app_sg.id}"]
  user_data = "${data.template_file.app_init.rendered}"

}

# Auto Scaling Group

resource "aws_autoscaling_group" "app_scaling_group" {
  name = "${var.app_name}-scale-group"
  max_size = 3
  min_size = 3
  launch_configuration = "${aws_launch_configuration.app_launch_conf.name}"
  vpc_zone_identifier = ["${aws_subnet.app_subnet-a.id}", "${aws_subnet.app_subnet-b.id}", "${aws_subnet.app_subnet-c.id}"]

  tag {
    key = "Name"
    value = "${var.app_name}-asg"
    propagate_at_launch = true
  }

}

# Autoscaling Group Attachment
resource "aws_autoscaling_attachment" "app_scaling_attach" {
  autoscaling_group_name = "${aws_autoscaling_group.app_scaling_group.id}"
  alb_target_group_arn   = "${aws_lb_target_group.app_target_group.arn}"
}
