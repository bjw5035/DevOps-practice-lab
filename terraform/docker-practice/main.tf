resource "docker_network" "tf-practice-net" {
  name = "tf-practice-net"
}

resource "docker_image" "devops-practice-lab" {
  name = "jjwoos/devops-practice-lab:latest"
}

resource "docker_container" "devops-practice-lab" {
  name  = "devops-practice-lab"
  image = docker_image.devops-practice-lab.image_id

  networks_advanced {
    name = docker_network.tf-practice-net.name
  }

  ports {
    internal = 8000
    external = 8080
    protocol = "tcp"
  }

  volumes {
    volume_name = docker_volume.tf-practice-vol.name
    container_path = "/data"
  }
}

resource "docker_volume" "tf-practice-vol" {
  name = "tf-practice-vol"
}