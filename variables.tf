variable "identifier" {
  type        = string
  description = "Identifer used to name resources created by the module."
}
variable "vpc_id" {
  type        = string
  description = "The id of the VPC in which the reverse tunnel will be deployed."
}
variable "image_name" {
  type        = string
  description = "Name of the container image to use."
  default     = "public.ecr.aws/entrinsik-inc/data-gateway"
}
variable "image_tag" {
  type        = string
  description = "Tag of the container image to use."
  # TODO(jkinred): Investigate whether Entrinsik offers an immutable tag
  default     = "latest"
}
variable "ecs_service_subnets" {
  type        = list(string)
  description = "List of subnets to associate with the ECS service"
}
variable "datahub_port" {
  type        = number
  description = "The port on our Datahub that you want for the remote end of the tunnel"
}
variable "datasource_address" {
  type        = string
  description = "The address of the datasource to proxy to."
}
variable "datasource_port" {
  type        = number
  description = "The port of the datasource to proxy to."
}
variable "datahub_cidrs" {
  type        = list(string)
  description = "List of CIDR's that the tunnel container will be allowed to connect to."
  default     = ["0.0.0.0/0"]
}
variable "tunnel_parameter_store_prefix" {
  type = string
  default = "informer"
}
