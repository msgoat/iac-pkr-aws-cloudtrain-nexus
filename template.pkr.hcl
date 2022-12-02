packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "nexus" {
  ami_name      = "CloudTrain-Nexus3-${var.revision}-${legacy_isotime("20060102")}-x86_64-gp2"
  instance_type = var.ec2_instance_type
  region        = var.region_name
  source_ami    = var.source_ami_id
  #  source_ami_filter {
  #    filters = {
  #      architecture        = "x86_64"
  #      name                = "amazon/amzn2-ami-*"
  #      root-device-type    = "ebs"
  #      virtualization-type = "hvm"
  #    }
  #    most_recent = true
  #    owners      = ["amazon"] # Amazon
  #  }
  ssh_username = "ec2-user"
  launch_block_device_mappings {
    device_name = "/dev/xvda"
    encrypted = true
    volume_type = "gp3"
    volume_size = 8
    delete_on_termination = true
  }
  launch_block_device_mappings {
    device_name = "/dev/xvdb"
    encrypted = true
    volume_type = "gp3"
    volume_size = 32
    delete_on_termination = false
  }
  tags = {
    Base_AMI_Name = "{{ .SourceAMIName }}"
    Department    = "Automotive Academy"
    Extra         = "<no value>"
    Maintainer    = "Michael Theis (msg)"
    OS_Version    = "Amazon Linux 2"
    Organization  = "msg systems ag"
    Project       = "CloudTrain"
    Release       = "Latest"
  }
}

build {
  sources = ["source.amazon-ebs.nexus"]

  provisioner "file" {
    sources = [
      "./resources/nexus.rc",
      "./resources/nexus.service",
      "./resources/nexus.vmoptions",
    ]
    destination = "/tmp/"
  }

  provisioner "shell" {
    scripts = [
      "./scripts/00_init.sh",
      "./scripts/01_mount_data_volume.sh",
      "./scripts/02_install_awscli2.sh",
      "./scripts/03_install_java8.sh",
      "./scripts/04_install_nexus3.sh",
    ]
  }

}

variable region_name {
  description = "AWS region name"
  type        = string
  default     = "eu-west-1"
}

variable revision {
  description = "Revision number (major.minor.path) of the AMI"
  type        = string
  default     = "0.12.0"
}

# TODO: try to replace with AMI filter
variable source_ami_id {
  description = "Unique identifier of the source AMI"
  type        = string
  default     = "ami-0ee415e1b8b71305f" # Amazon Linux 2 AMI (HVM) - Kernel 5.10, SSD Volume Type
}

variable ec2_instance_type {
  description = "EC2 instance type name"
  type        = string
  default     = "t3a.micro"
}
