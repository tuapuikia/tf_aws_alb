### ALB resources

# TODO:
# support not logging

resource "aws_alb" "main" {
  name            = "${var.alb_name}"
  subnets         = ["${var.subnets}"]
  security_groups = ["${var.alb_security_groups}"]
  internal        = "${var.alb_is_internal}"
  idle_timeout    = "${var.idle_timeout}"

  tags = "${merge(var.tags, map("Name", format("%s", var.alb_name)))}"
}

resource "aws_alb_target_group" "target_group" {
  name     = "${var.alb_name}-tg"
  port     = "${var.backend_port}"
  protocol = "${upper(var.backend_protocol)}"
  vpc_id   = "${var.vpc_id}"

  health_check {
    interval            = 30
    path                = "${var.health_check_path}"
    port                = "${var.health_check_port}"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    protocol            = "${var.backend_protocol}"
  }

  stickiness {
    type            = "lb_cookie"
    cookie_duration = "${var.cookie_duration}"
    enabled         = "${ var.cookie_duration == 1 ? false : true}"
  }

  tags = "${merge(var.tags, map("Name", format("%s-tg", var.alb_name)))}"

  count = "${chomp(var.alb_default_target_group_name) != "" ? 0 : 1}"
}

data "aws_alb_target_group" "existing_target_group" {
  name  = "${chomp(var.alb_default_target_group_name)}"
  count = "${chomp(var.alb_default_target_group_name) != "" ? 1 : 0}"
}

resource "aws_alb_listener" "front_end_http" {
  load_balancer_arn = "${aws_alb.main.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
	# The join() hack is required because currently the ternary operator
	# evaluates the expressions on both branches of the condition before
	# returning a value. When providing and external VPC, the template VPC
	# resource gets a count of zero which triggers an evaluation error.
	#
	# This is tracked upstream: https://github.com/hashicorp/hil/issues/50
	#
    target_group_arn = "${chomp(var.alb_default_target_group_name) != "" ? join(" ", data.aws_alb_target_group.existing_target_group.*.arn) : join(" ", aws_alb_target_group.target_group.*.arn)}"
    type             = "forward"
  }

  count = "${trimspace(element(split(",", var.alb_protocols), 1)) == "HTTP" || trimspace(element(split(",", var.alb_protocols), 2)) == "HTTP" ? 1 : 0}"
}

resource "aws_alb_listener" "front_end_https" {
  load_balancer_arn = "${aws_alb.main.arn}"
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = "${var.certificate_arn}"
  ssl_policy        = "${var.alb_ssl_policy}"

  default_action {
	# The join() hack is required because currently the ternary operator
	# evaluates the expressions on both branches of the condition before
	# returning a value. When providing and external VPC, the template VPC
	# resource gets a count of zero which triggers an evaluation error.
	#
	# This is tracked upstream: https://github.com/hashicorp/hil/issues/50
	#
    target_group_arn = "${chomp(var.alb_default_target_group_name) != "" ? join(" ", data.aws_alb_target_group.existing_target_group.*.arn) : join(" ", aws_alb_target_group.target_group.*.arn)}"
    type             = "forward"
  }

  count = "${trimspace(element(split(",", var.alb_protocols), 1)) == "HTTPS" || trimspace(element(split(",", var.alb_protocols), 2)) == "HTTPS" ? 1 : 0}"
}
