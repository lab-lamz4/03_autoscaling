module "asg" {
  # asg
  source                        = "../../modules/asg"
  enable_asg                    = true
  asg_name                      = "asg-test"
  asg_launch_template           = [{
    id      = module.lt.launch_template_id
    version = module.lt.launch_template_latest_version
  }]
  asg_vpc_zone_identifier       = module.vpc.private_subnets_ids
  asg_max_size                  = 2
  asg_min_size                  = 1
  asg_desired_capacity          = 1
  asg_wait_for_capacity_timeout = 0
  asg_health_check_grace_period = 500
  asg_tags = [
    {
      key                 = "Orchestration"
      value               = "Terraform"
      propagate_at_launch = true
    },
    {
      key                 = "Environment"
      value               = "learning"
      propagate_at_launch = true
    }
  ]

}

resource "aws_autoscaling_policy" "cpu" {
  name                   = "asg_scaling_policy"
  autoscaling_group_name = "asg-test"
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 80.0
  }
  depends_on = [
    module.asg
  ]
}