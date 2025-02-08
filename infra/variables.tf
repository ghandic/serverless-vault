variable "vaultwarden_admin_password" {
  description = "The password to access the admin panel"
}

variable "vaultwarden_admin_salt" {
  description = "The password salt for the argon2 hash"
}

variable "gateway_domain" {
  description = "The domain that shall be used for API Gateway, i.e. where vaultwarden will be accessible after"
}

variable "aws_region" {
  description = "The AWS region to deploy vaultwarden-serverless in"
}

variable "resend_api_key" {
  description = "The resend API key for SMTP"
}

variable "smtp_from" {
  description = "The email address to send emails from"
}

variable "neon_api_key" {
  description = "The NEON API key"
}
