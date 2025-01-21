# This Terraform file creates the following variables:
# - A profile variable
# - A AWS region variable
# - A Cloudgoat ID variable
# - A Cloudgoat IP whitelist variable
# - A Public SSH key variable 
# - A Private SSH key variable
# - A 'stack' name variable
# - A scenario name variable

#Required: AWS Profile
variable "profile" {
  description = "The AWS profile to use."
  type        = string
}
#Required: AWS Region
variable "region" {
  description = "The AWS region to deploy resources to."
  default = "us-west-2"
  type        = string
}
#Required: CGID Variable for unique naming
variable "cgid" {
  description = "CGID variable for unique naming."
  type        = string
}
#Required: User's Public IP Address(es)
variable "cg_whitelist" {
  description = "User's public IP address(es)."
  type        = list(string)
}
#SSH Public Key
variable "ssh-public-key-for-ec2" {
  default = "../cloudgoat.pub"
}
#SSH Private Key
variable "ssh-private-key-for-ec2" {
  default = "../cloudgoat"
}
#Stack Name
variable "stack-name" {
  description = "Name of the stack."
  default     = "CloudGoat"
  type        = string
}
#Scenario Name
variable "scenario-name" {
  description = "Name of the scenario."
  default = "secrets_in_the_cloud"
  type        = string
}
