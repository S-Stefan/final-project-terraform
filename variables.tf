variable "name" {
  default = "eng22"
}

variable "app_name" {
  default = "eng22-app"
}

variable "db_name" {
  default = "eng22-db"
}

variable "app_ami_id" {
  default = "ami-0672304de0a0ed8c3"
}

variable "db_ami_id" {
  default = "ami-0d133d6eafbc7a1d4"
}

variable "heartbeat_name" {
  default = "eng22-heartbeat"
}

variable "heartbeat_ami_id" {
  default = "ami-02160dbdbecc1e1e9"
}

variable "logstash_name" {
  default = "eng22-logstash"
}

variable "logstash_ami_id" {
  default = "ami-0542cdb441165bc3b"
}

variable "elasticsearch_name" {
  default = "eng22-elasticsearch"
}

variable "elasticsearch_ami_id" {
  default = "ami-05b64ac9225137f3a"
}

variable "kibana_name" {
  default = "eng22-kibana"
}

variable "kibana_ami_id" {
  default = "ami-005c19b5a51de086c"
}
