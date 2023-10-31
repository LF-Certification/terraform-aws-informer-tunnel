module "informer-tunnel" {
  source              = "git::https://github.com/LF-Certification/terraform-aws-informer-tunnel.git"
  identifier          = "informer-secure-tunnel"
  # Typically obtained from the output of another resource
  vpc_id              = "vpc-12345"
  ecs_service_subnets = ["subnet-4321", "subnet-8765"]
  datahub_port        = 15432
  datasource_address  = "database.hostname.org"
  datasource_port     = 5432
}
