resource "aws_instance" "control_plane" {
  ami                    = var.ami
  instance_type          = "t3.medium"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_name

  tags = {
    Name = "${var.project}-control-plane"
    Role = "control-plane"
  }
}

resource "aws_instance" "workers" {
  count                  = 2
  ami                    = var.ami
  instance_type          = "t3.medium"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_name

  tags = {
    Name = "${var.project}-worker-${count.index + 1}"
    Role = "worker"
  }
}
