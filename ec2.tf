data "aws_subnet" "public" {
  for_each = toset(module.vpc.public_subnets_ids)

  id = each.key
  depends_on = [
    module.vpc
  ]
}

data "aws_subnet" "private" {
  for_each = toset(module.vpc.private_subnets_ids)

  id = each.key
  depends_on = [
    module.vpc
  ]
}

locals {
  public_az       = {
    for s in data.aws_subnet.public : s.availability_zone => s.id
  }
  private_az       = {
    for s in data.aws_subnet.private : s.availability_zone => s.id
  }
}

module "ec2-bastion" {
  source = "../../modules/ec2"
  name   = "bastion-01"
  region = "us-east-1"
  ami    = {
      us-east-1 = "ami-0ab4d1e9cf9a1215a"
  }

  enable_instance             = true
  environment                 = "learning"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  root_block_device           = [{
      delete_on_termination = true
      volume_size           = 20
      volume_type           = "gp2"
  }]

  ebs_block_device            = [{
      delete_on_termination = true
      device_name           = "/dev/sdf"
      encrypted             = false
      volume_size           = 40
      volume_type           = "gp2"
  }]

  disk_size                             = null
  tenancy                               = "default"
  subnet_id                             = lookup(local.public_az, "us-east-1c")
  vpc_security_group_ids                = [module.sg.security_group_id]
  user_data                             = file("additional_files/bastion.yaml")
  instance_initiated_shutdown_behavior  = "terminate"
  monitoring                            = true
  tags = tomap({
    "Environment"   = "learning",
    "stack" =  "autoscaling"
    "Owner"     = "Andrei Leodorov",
    "Orchestration" = "Terraform"
  })

  depends_on = [
    module.vpc,
    module.sg
  ]
}
