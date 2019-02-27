output instance_private_ip {
  value = "${"aws_instance.db_instance.private_ip"}"
}
