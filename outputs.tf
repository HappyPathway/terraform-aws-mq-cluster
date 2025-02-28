output "broker_id" {
  description = "The ID of the broker"
  value       = aws_mq_broker.main.id
}

output "broker_arn" {
  description = "ARN of the broker"
  value       = aws_mq_broker.main.arn
}

output "broker_instances" {
  description = "List of broker instances"
  value       = aws_mq_broker.main.instances
}

output "broker_endpoint" {
  description = "The primary endpoint of the broker"
  value       = aws_mq_broker.main.instances[0].endpoints[0]
}