output instance_private_ip {
  value = "${aws_instance.db_instance.private_ip}"
}

output instance_private_ip_secondary_1 {
  value = "${aws_instance.db_instance_secondary_1.private_ip}"
}

output instance_private_ip_secondary_2 {
  value = "${aws_instance.db_instance_secondary_2.private_ip}"
}
