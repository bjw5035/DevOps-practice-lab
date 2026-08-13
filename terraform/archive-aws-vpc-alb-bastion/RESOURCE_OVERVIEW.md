# Terraform AWS Resource Overview

이 문서는 Terraform으로 정의한 AWS 리소스의 역할과 사용 목적을 정리한 문서입니다.

현재 프로젝트는 Terraform을 사용하여 AWS 기본 인프라를 코드로 정의하고, `terraform validate`와 `terraform plan`을 통해 생성 예정 리소스를 검증하는 것을 목표로 합니다.

## 생성 예정 리소스 목록

현재 `terraform plan` 기준 생성 예정 리소스는 총 15개입니다.

| 구분            | Terraform 리소스                          | AWS 리소스                   | 역할                                     |
| ------------- | -------------------------------------- | ------------------------- | -------------------------------------- |
| Network       | `aws_vpc.main`                         | VPC                       | AWS 내부에 독립적인 네트워크 영역 생성                |
| Network       | `aws_subnet.public_a`                  | Public Subnet             | 외부 접근이 가능한 리소스 배치 영역                   |
| Network       | `aws_subnet.public_c`                  | Public Subnet             | 고가용성을 고려한 두 번째 Public Subnet           |
| Network       | `aws_subnet.private_a`                 | Private Subnet            | 외부에서 직접 접근하지 않는 내부 리소스 배치 영역           |
| Network       | `aws_subnet.private_c`                 | Private Subnet            | 고가용성을 고려한 두 번째 Private Subnet          |
| Network       | `aws_internet_gateway.main`            | Internet Gateway          | VPC와 인터넷을 연결                           |
| Network       | `aws_route_table.public`               | Route Table               | Public Subnet의 인터넷 라우팅 경로 정의           |
| Network       | `aws_route_table_association.public_a` | Route Table Association   | Public Subnet A와 Public Route Table 연결 |
| Network       | `aws_route_table_association.public_c` | Route Table Association   | Public Subnet C와 Public Route Table 연결 |
| Security      | `aws_security_group.bastion`           | Security Group            | Bastion EC2 접근 제어                      |
| Security      | `aws_security_group.alb`               | Security Group            | ALB HTTP 접근 제어                         |
| Compute       | `aws_instance.bastion`                 | EC2 Instance              | Bastion 또는 테스트용 서버 인스턴스                |
| Load Balancer | `aws_lb.main`                          | Application Load Balancer | 외부 HTTP 트래픽 수신                         |
| Load Balancer | `aws_lb_target_group.main`             | Target Group              | ALB가 트래픽을 전달할 대상 그룹                    |
| Load Balancer | `aws_lb_listener.http`                 | Listener                  | ALB의 HTTP 80 포트 요청 처리 규칙               |

## Network 리소스

### `aws_vpc.main`

VPC는 AWS에서 네트워크를 구성하기 위한 가장 기본적인 리소스입니다.

이 프로젝트에서는 `10.0.0.0/16` CIDR 대역을 사용하는 VPC를 생성하여 Public Subnet, Private Subnet, Route Table, Security Group 등의 네트워크 리소스를 배치할 수 있는 기반을 만듭니다.

사용 목적:

* AWS 내 독립적인 네트워크 영역 구성
* Public/Private Subnet 분리 기반 제공
* 보안그룹, 라우팅, 로드밸런서 등 네트워크 리소스의 상위 기준 제공

비용:

* VPC 자체는 일반적으로 별도 비용이 발생하지 않습니다.

---

### `aws_subnet.public_a`, `aws_subnet.public_c`

Public Subnet은 인터넷 접근이 필요한 리소스를 배치하는 영역입니다.

이 프로젝트에서는 서로 다른 Availability Zone에 Public Subnet을 2개 구성합니다. 이는 ALB 같은 리소스가 여러 가용 영역에 걸쳐 배치될 수 있도록 하기 위한 구조입니다.

사용 목적:

* 인터넷 접근이 필요한 리소스 배치
* ALB 배치 영역 제공
* Bastion EC2 또는 Public EC2 배치 가능
* 다중 AZ 구성을 통한 기본적인 고가용성 구조 학습

비용:

* Subnet 자체는 별도 비용이 발생하지 않습니다.
* 다만 Subnet 안에 배치되는 EC2, ALB 등의 리소스는 비용이 발생할 수 있습니다.

---

### `aws_subnet.private_a`, `aws_subnet.private_c`

Private Subnet은 외부 인터넷에서 직접 접근하지 않는 내부 리소스를 배치하기 위한 영역입니다.

현재 프로젝트에서는 실제 RDS나 내부 애플리케이션 서버를 생성하지는 않지만, 클라우드 네트워크 설계 관점에서 Public/Private 구조를 구분하기 위해 Private Subnet을 정의합니다.

사용 목적:

* 내부 서버, 데이터베이스, 애플리케이션 서버 배치 영역 설계
* 외부 직접 접근을 차단하는 네트워크 구조 학습
* 향후 RDS, 내부 EC2, EKS Worker Node 등 확장 가능성 확보

비용:

* Private Subnet 자체는 별도 비용이 발생하지 않습니다.
* NAT Gateway를 붙이면 비용이 발생하므로 현재 단계에서는 NAT Gateway를 제외합니다.

---

### `aws_internet_gateway.main`

Internet Gateway는 VPC가 인터넷과 통신할 수 있도록 연결하는 리소스입니다.

Public Subnet이 실제로 인터넷과 통신하려면 VPC에 Internet Gateway가 연결되어 있어야 하고, Route Table에서 `0.0.0.0/0` 경로가 Internet Gateway를 바라봐야 합니다.

사용 목적:

* VPC와 인터넷 연결
* Public Subnet의 외부 통신 기반 제공
* ALB 또는 Public EC2 접근 가능 구조 구성

비용:

* Internet Gateway 자체는 일반적으로 별도 비용이 발생하지 않습니다.
* 단, 인터넷 데이터 전송 비용은 발생할 수 있습니다.

---

### `aws_route_table.public`

Route Table은 Subnet의 트래픽이 어디로 이동해야 하는지 정의하는 리소스입니다.

이 프로젝트의 Public Route Table은 `0.0.0.0/0` 경로를 Internet Gateway로 보내도록 구성합니다. 이를 통해 Public Subnet에 위치한 리소스가 인터넷과 통신할 수 있습니다.

사용 목적:

* Public Subnet의 인터넷 라우팅 경로 정의
* Internet Gateway와 Public Subnet 연결 흐름 구성
* 네트워크 트래픽 흐름 이해

비용:

* Route Table 자체는 별도 비용이 발생하지 않습니다.

---

### `aws_route_table_association.public_a`, `aws_route_table_association.public_c`

Route Table Association은 특정 Subnet에 Route Table을 연결하는 리소스입니다.

Route Table을 만들기만 해서는 Subnet에 적용되지 않습니다. Public Subnet A와 Public Subnet C가 Public Route Table을 사용하도록 명시적으로 연결해야 합니다.

사용 목적:

* Public Subnet과 Public Route Table 연결
* 각 Subnet의 라우팅 정책 적용
* Public Subnet이 실제로 인터넷 경로를 사용할 수 있도록 구성

비용:

* Route Table Association 자체는 별도 비용이 발생하지 않습니다.

---

## Security 리소스

### `aws_security_group.bastion`

Bastion Security Group은 EC2 인스턴스에 대한 접근을 제어하는 보안 리소스입니다.

현재 프로젝트에서는 SSH 접근을 허용하기 위해 22번 포트를 설정합니다. 실무에서는 `0.0.0.0/0`으로 SSH를 열지 않고, 본인 공인 IP 또는 사내 VPN 대역만 허용해야 합니다.

사용 목적:

* EC2 SSH 접근 제어
* 허용된 CIDR에서만 접속 가능하도록 제한
* 인스턴스 접근 보안 관리

보안 주의점:

* SSH 22번 포트는 반드시 제한된 CIDR만 허용해야 합니다.
* `allowed_ssh_cidr` 변수를 사용하여 접근 대역을 관리합니다.
* `terraform.tfvars`에는 실제 공인 IP가 들어갈 수 있으므로 Git에 업로드하지 않습니다.

비용:

* Security Group 자체는 별도 비용이 발생하지 않습니다.

---

### `aws_security_group.alb`

ALB Security Group은 Application Load Balancer로 들어오는 트래픽을 제어하는 보안 리소스입니다.

현재 프로젝트에서는 HTTP 80 포트를 허용하여 외부 요청을 받을 수 있는 구조를 정의합니다.

사용 목적:

* ALB로 들어오는 HTTP 접근 제어
* 외부 트래픽 진입 지점 관리
* ALB와 내부 대상 리소스 간 접근 구조 분리

보안 주의점:

* HTTP 80 포트는 외부 공개가 가능하지만, 운영 환경에서는 HTTPS 443 적용을 고려해야 합니다.
* 실제 서비스 환경에서는 인증서, 도메인, HTTPS 리다이렉션 정책이 추가될 수 있습니다.

비용:

* Security Group 자체는 별도 비용이 발생하지 않습니다.

---

## Compute 리소스

### `aws_instance.bastion`

EC2 인스턴스는 AWS에서 가상 서버 역할을 하는 컴퓨팅 리소스입니다.

현재 프로젝트에서는 Bastion 또는 테스트용 인스턴스로 정의되어 있습니다. Bastion은 일반적으로 Private Subnet 내부 리소스에 접근하기 위한 중간 접속 서버 역할을 합니다.

사용 목적:

* Terraform을 통한 EC2 생성 구조 학습
* Public Subnet에 배치되는 서버 리소스 구성
* SSH 접근 및 보안그룹 연결 구조 확인
* 향후 내부 리소스 접근용 Bastion 구조로 확장 가능

비용:

* EC2는 인스턴스 타입과 실행 시간에 따라 비용이 발생합니다.
* 실습 후 반드시 `terraform destroy`로 삭제해야 합니다.

---

## Load Balancer 리소스

### `aws_lb.main`

Application Load Balancer는 외부 HTTP/HTTPS 트래픽을 받아 Target Group으로 전달하는 로드밸런서 리소스입니다.

이 프로젝트에서는 Public Subnet 2개에 걸쳐 ALB를 배치하는 구조를 정의합니다. 이는 다중 가용 영역 기반의 기본적인 로드밸런싱 구조를 학습하기 위한 목적입니다.

사용 목적:

* 외부 HTTP 트래픽 수신
* Target Group으로 트래픽 전달
* 다중 AZ 기반 로드밸런서 구조 학습
* 향후 EC2, ECS, EKS 등과 연결 가능한 확장 구조 제공

비용:

* ALB는 생성 후 실행 시간 기준으로 비용이 발생합니다.
* 현재 단계에서는 비용 방지를 위해 필요할 때만 생성하고, 확인 후 삭제하는 방식을 사용합니다.

---

### `aws_lb_target_group.main`

Target Group은 ALB가 트래픽을 전달할 대상 리소스의 그룹입니다.

일반적으로 EC2 인스턴스, IP, Lambda 등이 Target Group에 등록될 수 있습니다. ALB는 Listener 규칙에 따라 들어온 요청을 Target Group으로 전달합니다.

사용 목적:

* ALB 트래픽 전달 대상 정의
* Health Check 기준 설정
* EC2 또는 컨테이너 기반 서비스와 ALB 연결 준비

비용:

* Target Group 자체보다는 ALB 사용에 따른 비용이 발생합니다.
* Health Check 대상 리소스가 EC2라면 해당 EC2 비용도 고려해야 합니다.

---

### `aws_lb_listener.http`

Listener는 ALB가 어떤 포트와 프로토콜로 요청을 받을지 정의하는 리소스입니다.

현재 프로젝트에서는 HTTP 80 포트 요청을 받아 Target Group으로 전달하는 구조입니다.

사용 목적:

* ALB의 HTTP 80 포트 수신 규칙 정의
* 요청을 Target Group으로 전달
* 향후 HTTPS 443, 인증서, 리다이렉션 정책으로 확장 가능

비용:

* Listener 자체가 별도 과금의 핵심은 아니지만, ALB 리소스 사용 비용에 포함됩니다.

---

## 비용 관리 기준

현재 프로젝트에서 비용 발생 가능성이 있는 주요 리소스는 다음과 같습니다.

| 리소스              | 비용 발생 가능성 | 관리 기준           |
| ---------------- | --------: | --------------- |
| VPC              |        낮음 | 기본 네트워크 리소스     |
| Subnet           |        낮음 | 자체 비용 없음        |
| Internet Gateway |        낮음 | 자체 비용 없음        |
| Route Table      |        낮음 | 자체 비용 없음        |
| Security Group   |        낮음 | 자체 비용 없음        |
| EC2              |        높음 | 생성 후 즉시 destroy |
| ALB              |        높음 | 생성 후 즉시 destroy |
| Target Group     |        중간 | ALB와 함께 관리      |
| Listener         |        중간 | ALB와 함께 관리      |

비용 방지를 위해 현재 프로젝트에서는 다음 원칙을 따릅니다.

* `terraform plan`으로 생성 예정 리소스를 먼저 확인합니다.
* 실제 생성이 필요한 경우에만 `terraform apply`를 실행합니다.
* 생성 후 검증이 끝나면 `terraform destroy`로 리소스를 삭제합니다.
* NAT Gateway, RDS, EKS 등 지속 과금 가능성이 큰 리소스는 현재 단계에서 제외합니다.

