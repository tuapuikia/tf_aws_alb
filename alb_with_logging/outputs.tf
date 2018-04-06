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
  value = "${aws_alb_listener.front_end_http.*.arn}"
}

output "alb_listener_https_arn" {
  value = "${aws_alb_listener.front_end_https.*.arn}"
}

output "target_group_arn" {
	# The join() hack is required because currently the ternary operator
	# evaluates the expressions on both branches of the condition before
	# returning a value. When providing and external VPC, the template VPC
	# resource gets a count of zero which triggers an evaluation error.
	#
	# This is tracked upstream: https://github.com/hashicorp/hil/issues/50
	#
    value = "${chomp(var.alb_default_target_group_name) != "" ? join(" ", data.aws_alb_target_group.existing_target_group.*.arn) : join(" ", aws_alb_target_group.target_group.*.arn)}"
}

output "principal_account_id" {
  description = "The AWS-owned account given permissions to write your ALB logs to S3."
  value       = "${data.aws_elb_service_account.main.id}"
}
