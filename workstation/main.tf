terraform {
  required_version = "~> 0.11"
}

provider "digitalocean" {}

variable "region" {
  default = "sfo2"
}

resource "digitalocean_volume" "dev" {
  name                    = "dev"
  region                  = "${var.region}"
  size                    = 10
  initial_filesystem_type = "ext4"
  description             = "volume for dev"

  lifecycle {
    prevent_destroy = true
  }
}

resource "digitalocean_droplet" "dev" {
  count              = 0
  name               = "dev"
  image              = "ubuntu-19-04-x64"
  size               = "s-1vcpu-2gb"
  region             = "${var.region}"
  private_networking = true
  backups            = true
  ipv6               = true
  ssh_keys           = [25295573]                        # doctl compute ssh-key list
  volume_ids         = ["${digitalocean_volume.dev.id}"]

  provisioner "file" {
    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"

    connection {
      type        = "ssh"
      private_key = "${file("~/.ssh/ipad_rsa")}"
      user        = "root"
      timeout     = "2m"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "/tmp/bootstrap.sh initialize",
    ]

    connection {
      type        = "ssh"
      private_key = "${file("~/.ssh/ipad_rsa")}"
      user        = "root"
      timeout     = "2m"
    }
  }
}

resource "digitalocean_firewall" "dev" {
  name = "dev"

  droplet_ids = ["${digitalocean_droplet.dev.*.id}"]

  inbound_rule = [
    {
      protocol         = "tcp"
      port_range       = "22"
      source_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol         = "udp"
      port_range       = "60000-60010"
      source_addresses = ["0.0.0.0/0", "::/0"]
    },
  ]

  outbound_rule = [
    {
      protocol              = "tcp"
      port_range            = "1-65535"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol              = "udp"
      port_range            = "1-65535"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol              = "icmp"
      destination_addresses = ["0.0.0.0/0", "::/0"]
    },
  ]
}

output "public_ip" {
  value = "${digitalocean_droplet.dev.*.ipv4_address}"
}
