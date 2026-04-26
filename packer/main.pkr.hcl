packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.0.0"
    }
  }
}

variable "region" {
  default = "ap-southeast-2"
}

source "amazon-ebs" "ami" {
  region                  = var.region
  instance_type           = "t2.micro"
  ssh_username            = "ec2-user"

  ami_name                = "custom-httpd-ami-{{timestamp}}"

  source_ami_filter {
    filters = {
      name                = "amzn2-ami-hvm-*-x86_64-gp2"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["amazon"]
    most_recent = true
  }
}

build {
  name    = "httpd-ami"
  sources = ["source.amazon-ebs.ami"]

 provisioner "file" {
     
         source = "./website/"
         destination = "/tmp/website/"
}

  provisioner "shell" {
    inline = [
      "sudo yum update -y",
      "sudo yum install httpd -y",
      "sudo systemctl enable httpd",
      "sudo systemctl start httpd",
       "sudo cp -r /tmp/website/* /var/www/html/",
      "sudo chown -R apache:apache /var/www/html/",
    ]
  }

}

