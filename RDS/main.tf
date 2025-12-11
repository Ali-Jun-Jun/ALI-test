# 配置阿里云 Provider
provider "alicloud" {
  region = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

# 创建 VPC（专有网络）
resource "alicloud_vpc" "vpc" {
  vpc_name   = "${var.project_name}-vpc"
  cidr_block = var.vpc_cidr
}

# 创建 vSwitch（交换机）
resource "alicloud_vswitch" "vswitch" {
  vswitch_name = "${var.project_name}-vswitch"
  cidr_block   = var.vswitch_cidr
  vpc_id       = alicloud_vpc.vpc.id
  zone_id      = var.zone_id
}

# 创建安全组
resource "alicloud_security_group" "sg" {
  name        = "${var.project_name}-rds-sg"
  vpc_id      = alicloud_vpc.vpc.id
  description = "Security group for RDS instance"
}

# 允许来自指定 CIDR 的 MySQL 访问（3306 端口）
resource "alicloud_security_group_rule" "ingress_mysql" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "3306/3306"
  priority          = 1
  security_group_id = alicloud_security_group.sg.id
  cidr_ip           = var.allowed_cidr
}

# 创建 RDS 实例
resource "alicloud_db_instance" "rds" {
  db_instance_class = var.db_instance_class     # 例如 rds.mysql.t1.small
  db_instance_storage = var.db_instance_storage # 存储空间，单位 GB
  engine              = "MySQL"
  engine_version      = "8.0"
  instance_charge_type = "PostPaid"             # 按量付费，也可设为 PrePaid
  internet_connection_port = 3306
  period              = 1                       # 如果是包年包月需要设置周期
  vswitch_id          = alicloud_vswitch.vswitch.id
  security_ips        = ["0.0.0.0"]          # 可以改为你的公网 IP 或内网访问
  db_instance_net_type = "Intranet"
  security_group_ids    = [alicloud_security_group.sg.id]
  db_instance_description = "${var.project_name}-mysql-rds"
}

# 创建数据库
resource "alicloud_db_database" "db" {
  count        = length(var.database_names)
  instance_id  = alicloud_db_instance.rds.id
  name         = var.database_names[count.index]
  description  = "Database ${var.database_names[count.index]}"
  character_set = "utf8mb4"
}

# 创建数据库账号
resource "alicloud_db_account" "account" {
  instance_id = alicloud_db_instance.rds.id
  account_name = var.db_username
  password     = var.db_password
  account_type = "Super"
  account_privilege = "ReadWrite"
  db_names          = var.database_names
}
