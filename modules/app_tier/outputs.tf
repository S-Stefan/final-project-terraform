output security_group_id {
  value = "${aws_security_group.app_sg.id}"
}

output lb_dns_name {
  value = "${aws_lb.app_load_balancer.dns_name}"
}

output lb_zone_id {
  value = "${aws_lb.app_load_balancer.zone_id}"
}
