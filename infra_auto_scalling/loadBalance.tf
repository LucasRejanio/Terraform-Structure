#Security group
resource "aws_security_group" "lb-sg" {
  name        = "LB-SG"
  description = "Security Group Load Balance"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "LoadBalancer-SG"
  }
}

#Load Balace
resource "aws_lb" "lb" {
  name            = "LB"
  security_groups = ["${aws_security_group.lb-sg.id}"]
  subnets         = ["${aws_subnet.public_a.id}", "${aws_subnet.public_b.id}"]

  tags = {
    Name = "Load-Balance"
  }

}

#Target Load Balance
resource "aws_lb_target_group" "lb-tg" {
  name     = "LB-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.vpc.id}"

  health_check {
    path              = "/"
    healthy_threshold = 2
  }
}

#Listener Load Balance
resource "aws_lb_listener" "lb-listener" {
  load_balancer_arn = "${aws_lb.lb.arn}"
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.lb-tg.arn}"
  }
}

