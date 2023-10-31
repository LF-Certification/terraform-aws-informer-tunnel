<!-- BEGIN_TF_DOCS -->
# Informer Datahub Tunnel

An ECS based SSH reverse proxy used as a secure tunnel to the Entrinsik
Datahub.

## Troubleshooting

It is possible to enter the ECS container running the tunnel with the
following command:

```
aws ecs execute-command \
    --region <REGION> \
    --cluster <CLUSTER> \
    --task <TASK_ID> \
    --container ssh-reverse-tunnel \
    --command "/bin/bash" \
    --interactive
```

## Example

```hcl
module "informer-tunnel" {
  source              = "git::https://github.com/LF-Certification/terraform-aws-informer-tunnel.git"
  identifier          = "faraday-informer-secure-tunnel"
  # Typically obtained from the output of another resource
  vpc_id              = "vpc-12345"
  ecs_service_subnets = ["subnet-4321", "subnet-8765"]
  datahub_port        = 15432
  datasource_address  = "database.hostname.org"
  datasource_port     = 5432
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_datahub_cidrs"></a> [datahub\_cidrs](#input\_datahub\_cidrs) | List of CIDR's that the tunnel container will be allowed to connect to. | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_datahub_port"></a> [datahub\_port](#input\_datahub\_port) | The port on our Datahub that you want for the remote end of the tunnel | `number` | n/a | yes |
| <a name="input_datasource_address"></a> [datasource\_address](#input\_datasource\_address) | The address of the datasource to proxy to. | `string` | n/a | yes |
| <a name="input_datasource_port"></a> [datasource\_port](#input\_datasource\_port) | The port of the datasource to proxy to. | `number` | n/a | yes |
| <a name="input_ecs_security_groups"></a> [ecs\_security\_groups](#input\_ecs\_security\_groups) | Security groups which will be added to the ECS task | `list(string)` | `[]` | no |
| <a name="input_ecs_service_subnets"></a> [ecs\_service\_subnets](#input\_ecs\_service\_subnets) | List of subnets to associate with the ECS service | `list(string)` | n/a | yes |
| <a name="input_identifier"></a> [identifier](#input\_identifier) | Identifer used to name resources created by the module. | `string` | n/a | yes |
| <a name="input_image_name"></a> [image\_name](#input\_image\_name) | Name of the container image to use | `string` | `"public.ecr.aws/entrinsik-inc/data-gateway"` | no |
| <a name="input_image_tag"></a> [image\_tag](#input\_image\_tag) | Tag of the container image to use | `string` | `"latest"` | no |
| <a name="input_tunnel_parameter_store_prefix"></a> [tunnel\_parameter\_store\_prefix](#input\_tunnel\_parameter\_store\_prefix) | Prefix for parameters stored in AWS Parameter Store | `string` | `"informer"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The id of the VPC in which the reverse tunnel will be deployed. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->