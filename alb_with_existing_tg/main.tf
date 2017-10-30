### ALB resources

# TODO:
# support not logging

resource "aws_alb" "main" {
  name            = "${var.alb_name}"
  subnets         = ["${var.subnets}"]
  security_groups = ["${var.alb_security_groups}"]
  internal        = "${var.alb_is_internal}"

  tags = "${merge(var.tags, map("Name", format("%s", var.alb_name)))}"
}

data "aws_alb_target_group" "default" {
  name  = "${var.alb_default_target_group_name}"
}

resource "aws_alb_listener" "front_end_http" {
  load_balancer_arn = "${aws_alb.main.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${data.aws_alb_target_group.default.arn}"
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
    target_group_arn = "${data.aws_alb_target_group.default.arn}"
    type             = "forward"
  }

  count = "${trimspace(element(split(",", var.alb_protocols), 1)) == "HTTPS" || trimspace(element(split(",", var.alb_protocols), 2)) == "HTTPS" ? 1 : 0}"
}
