module "lt" {
  source      = "../../modules/asg"
  region      = "us-east-1"
  name        = "epam-leodorov-autoscaling"
  environment = "learning"

  enable_lt      = true
  lt_name        = "autoscaling-template"
  lt_description = "Autoscaling template module 03"
  
  lt_image_id               = "ami-0ab4d1e9cf9a1215a"
  lt_instance_type          = "t2.micro"
  lt_key_name               = "aws-learn"
  lt_user_data              = filebase64("additional_files/private-host.yaml")
  lt_instance_initiated_shutdown_behavior = "terminate"

  lt_network_interfaces     = [{
    associate_public_ip_address = false
    delete_on_termination       = true
    security_groups             = [module.sg-private.security_group_id]

  }]

  # lt_block_device_mappings = [{
  #   device_name = "/dev/sda1"
  #   volume_size = 20
  #   delete_on_termination = true
  # }]

}