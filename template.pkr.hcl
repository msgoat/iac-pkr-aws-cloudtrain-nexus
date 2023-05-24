packer {
  required_plugins {
    amazon = {
      version = "~> 1.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

locals {
  ami_name = "CloudTrain-Nexus3-${var.revision}-${legacy_isotime("20060102")}-${var.ami_architecture}-gp3"
}

source "amazon-ebs" "nexus" {
  ami_name      = local.ami_name
  instance_type = var.ec2_instance_type
  region        = var.region_name
  source_ami_filter {
    filters = {
      virtualization-type = "hvm"
      architecture        = "${var.ami_architecture}"
      name                = "amzn2-ami-kernel-5.10-hvm-2.0*"
      root-device-type    = "ebs"
    }
    most_recent = true
    owners      = ["137112412989"] # Amazon
  }
  ssh_username = "ec2-user"
  launch_block_device_mappings {
    device_name = "/dev/xvda"
    encrypted = true
    volume_type = "gp3"
    volume_size = 8
    delete_on_termination = true
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
    Name          = local.ami_name
  }
}

build {
  sources = ["source.amazon-ebs.nexus"]

  provisioner "file" {
    sources = [
      "./resources/nexus.rc",
      "./resources/nexus.service",
      "./resources/nexus.vmoptions.root_volume",
      "./resources/nexus.vmoptions.data_volume",
    ]
    destination = "/tmp/"
  }

  provisioner "shell" {
    env = {
      AMI_ARCHITECTURE = var.ami_architecture
      NEXUS_VERSION = var.nexus_version
    }
    scripts = [
      "./scripts/00_init.sh",
      "./scripts/02_install_awscli2.sh",
      "./scripts/03_install_java8.sh",
      "./scripts/04_install_nexus.sh",
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
  default     = "1.3.0"
}

variable ami_architecture {
  description = "Processor architecture of the AMI, allowed values are `x86_64` or `arm64`"
  type        = string
#  default     = "arm64"
  default     = "x86_64"
}

variable ec2_instance_type {
  description = "EC2 instance type name"
  type        = string
#  default     = "t4g.micro"
  default     = "t3.micro"
}

variable nexus_version {
  description = "Nexus OSS version number"
  type        = string
  default     = "3.54.1-01"
}
