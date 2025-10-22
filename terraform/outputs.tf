output "ec2_public_ip" {
  description = "Adresse IP publique de l’instance EC2"
  value       = aws_instance.lab_ec2.public_ip
}

output "dynamodb_table_name" {
  description = "Nom de la table DynamoDB créée"
  value       = aws_dynamodb_table.lab_table.name
}

