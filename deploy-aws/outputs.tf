output "public_ip" {
  description = "IP publica de la instancia"
  value       = aws_instance.juice_shop.public_ip
}

output "url" {
  description = "URL de Juice Shop (tarda ~2 min tras el apply en arrancar)"
  value       = "http://${aws_instance.juice_shop.public_ip}:3000"
}
