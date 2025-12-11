variable "region" {
  description = "阿里云地域"
  default     = "cn-beijing"
}

variable "zone_a" {
  description = "主可用区，如 cn-beijing-a"
  type        = string
}

variable "zone_b" {
  description = "备可用区，如 cn-beijing-h"
  type        = string
}

variable "access_key" {
  type        = string
  sensitive   = true
}

variable "secret_key" {
  type        = string
  sensitive   = true
}

variable "project_name" {
  description = "项目名称前缀"
  default     = "prod"
}

variable "vpc_cidr" {
  description = "VPC 网段"
  default     = "172.16.0.0/12"
}

variable "allowed_cidr" {
  description = "允许访问数据库的 IP 范围"
  default     = "0.0.0.0/0"  # 生产建议改为具体 IP
}

variable "db_instance_class" {
  description = "RDS 高可用规格，必须以 ha 开头"
  default     = "rds.mysql.ha.2xlarge"
}

variable "db_instance_storage" {
  description = "存储空间 (GB)"
  default     = 50
}

variable "database_names" {
  description = "要创建的数据库名列表"
  type        = list(string)
  default     = ["app_db", "log_db"]
}

variable "db_username" {
  description = "数据库管理员账号"
  default     = "adminuser"
}

variable "db_password" {
  description = "数据库密码"
  type        = string
  sensitive   = true
}
