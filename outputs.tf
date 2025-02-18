output "broker_id" {
  description = "Unique identifier for the broker"
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

output "primary_console_url" {
  description = "The URL of the primary broker's web console"
  value       = aws_mq_broker.main.primary_console_url
}

output "primary_endpoints" {
  description = "Map of protocol to primary endpoint URLs"
  value       = aws_mq_broker.main.primary_endpoints
}