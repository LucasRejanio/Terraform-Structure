resource "aws_security_group" "SG-Autoscaling" {
  name        = "Alto-Scaling"
  description = "Security Group Autoscaling"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.lb-sg.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SG-Auto-Scaling"
  }
}

resource "aws_launch_configuration" "lc" {
  name_prefix                 = "autoscaling-laucher"
  image_id                    = "${var.ami_linux}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  security_groups             = ["${aws_security_group.SG-Autoscaling.id}"]
  associate_public_ip_address = true

  user_data = "${file("ec2_setup.sh")}"
}

resource "aws_autoscaling_group" "auto-scaling" {
  name                      = "auto-scaling-terraform"
  vpc_zone_identifier       = ["${aws_subnet.public_a.id}", "${aws_subnet.public_b.id}"]
  launch_configuration      = "${aws_launch_configuration.lc.id}"
  min_size                  = 2
  max_size                  = 5
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true
  target_group_arns         = ["${aws_lb_target_group.lb-tg.id}"]
}

resource "aws_autoscaling_policy" "scaleup" {
  name                   = "Scale up"
  autoscaling_group_name = "${aws_autoscaling_group.auto-scaling.id}"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "1"
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}

resource "aws_autoscaling_policy" "scaledown" {
  name                   = "Scale Down"
  autoscaling_group_name = "${aws_autoscaling_group.auto-scaling.id}"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1"
  cooldown               = "300"
  policy_type            = "SimpleScaling"
}

resource "aws_instance" "jenkins" {
  ami           = "${var.ami_linux}"
  instance_type = "${var.instance_type}"

  vpc_security_group_ids = ["${aws_security_group.db.id}"]
  subnet_id              = "${aws_subnet.private_b.id}"
  availability_zone      = "${var.region}b"
  key_name               = "${var.key_name}"

  tags = {
    Name = "Terraform-Ec2-Private"
  }

}
