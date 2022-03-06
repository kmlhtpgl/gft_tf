output "vpc_id" {
  description = "ID of project VPC"
  value       = aws_vpc.main.id
}

output "lb_url" {
  description = "URL of load balancer"
  value       = aws_elb.myelb.arn
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.myec2.id
}

output "webserver_url" {
  description = "Public IP address of the EC2 instance"
  value       = "http://${aws_instance.myec2.public_ip}:80"
}