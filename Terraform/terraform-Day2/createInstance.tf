resource "aws_key_pair" "levelup_key" {
    key_name = levelup_key
    public_key = file(var.PUBLIC_KEY)
}

resource "aws_instance" "myFirstInstance" {
    ami = lookup(var.AWS_REGION,var.AMIS)
    instance_type = "t2.small"

    tags = {
        name = "custom-instance" 
    }

    provisioner "file" {
      source = "installNginx.sh"
      destination = "/tmp/installNginx.sh"
    }

    provisioner "remote-exec" {
        inline = [ 
            "chmod +x /tmp/installNginx.xh",
            "sudo /tmp/installNginx.sh"
         ]
      }

    connection {
      host = coalesce(self.public_ip,self.private_ip)
      type = "ssh"
      user = var.INSTANCE_USERNAME
      private_key = file(var.PRIVATE_KEY)
    }
}

