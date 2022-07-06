variable "ssh_host" {}
variable "ssh_user" {}
variable "ssh_key" {}
variable "ssh_password" {}

resource "null_resource" "ssh_target" {
  connection {
    type        = "ssh"
    user        = var.ssh_user
    host        = var.ssh_host
    private_key = file(var.ssh_key)
    password	= var.ssh_password
  }

  provisioner "file" {
    source      = "startup-options.conf"
    destination = "/tmp/startup-options.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo dnf update -y",
      "sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo",
      "sudo dnf install -y --allowerasing docker-ce",
      "sudo systemctl enable --now docker",
      "sudo mkdir -p /etc/systemd/system/docker.service.d/",
      "sudo cp /tmp/startup-options.conf /etc/systemd/system/docker.service.d/startup_options.conf",
      "sudo systemctl daemon-reload",
      "sudo systemctl restart docker",
      "sudo usermod -aG docker $USER",

    ]
  }
}
output "host" {
value = var.ssh_host
}
output "user" {
value = var.ssh_user
}