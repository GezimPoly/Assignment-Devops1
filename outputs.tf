output "web_public_ip" {
  description = "The public IP address of the web server"
  value = aws_eip.devops1_web_eip[0].public_ip

depends_on = [ aws_eip.devops1_web_eip ]

}

output "web_public_dns" {
  description = "The public DNS address of the web server"
value = aws_eip.devops1_web_eip[0].public_dns

depends_on=[aws_eip.devops1_web_eip]

}
output "databaseendpoint" {
    description = "The ednpoint of the database"
    value = aws_db_instance.devops1_database.address
  
}

output "database_port"{
    description = "The port of the database"
    value = aws_db_instance.devops1_database.port
}