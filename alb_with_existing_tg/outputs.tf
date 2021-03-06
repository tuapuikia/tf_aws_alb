output "alb_id" {
  value = "${aws_alb.main.id}"
}

output "alb_dns_name" {
  value = "${aws_alb.main.dns_name}"
}

output "alb_zone_id" {
  value = "${aws_alb.main.zone_id}"
}

output "alb_listener_http_arn" {
  value = "${aws_alb_listener.front_end_http.arn}"
}

output "alb_listener_https_arn" {
  value = "${aws_alb_listener.front_end_https.arn}"
}

output "target_group_arn" {
    value = "${data.aws_alb_target_group.default.arn}"
}

output "principle_account_id" {
  value = "${lookup(var.principle_account_id, var.aws_region)}"
}
