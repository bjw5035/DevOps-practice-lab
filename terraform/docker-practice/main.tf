resource "docker_network" "tf-practice-net" {
  name = "tf-practice-net"
}

resource "docker_image" "devops-practice-lab" {
  name = "jjwoos/devops-practice-lab:latest"
}

resource "docker_image" "nginx" {
  name = "nginx:latest"
}

resource "docker_image" "redis" {
  name = "redis:latest"
}

resource "docker_container" "redis" {
  name  = "redis"
  image = docker_image.redis.image_id

  networks_advanced {
    name = docker_network.tf-practice-net.name
  }

  ports {
    internal = 6379
    external = 6379
    protocol = "tcp"
  }
}

resource "docker_container" "nginx" {
  name  = "nginx"
  image = docker_image.nginx.image_id

  networks_advanced {
    name = docker_network.tf-practice-net.name
  }

  ports {
    internal = 80
    external = 8081
    protocol = "tcp"
  }
}

resource "docker_container" "devops-practice-lab" {
  name  = "devops-practice-lab"
  image = docker_image.devops-practice-lab.image_id
  env   = ["API_KEY=dev-key"]

  networks_advanced {
    name = docker_network.tf-practice-net.name
  }

  ports {
    internal = 8000
    external = 8080
    protocol = "tcp"
  }

  volumes {
    volume_name    = docker_volume.tf-practice-vol.name
    container_path = "/data"
  }

}

resource "docker_volume" "tf-practice-vol" {
  name = "tf-practice-vol"
}