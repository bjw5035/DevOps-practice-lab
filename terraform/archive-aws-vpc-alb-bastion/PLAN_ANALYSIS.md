# Terraform Plan Analysis

## 1. 목적

이 문서는 Terraform plan 결과를 기준으로 생성 예정 리소스를 분석하기 위한 문서입니다.

현재 프로젝트는 AWS 기본 인프라를 Terraform 코드로 정의하고 있으며, 실제 apply 전 plan 결과를 통해 어떤 리소스가 생성될지 검토합니다.

## 2. Plan 결과 요약

```text
Plan: 15 to add, 0 to change, 0 to destroy.


## 4. 생성 예정 리소스 상세 분석

| 구분            | Terraform 리소스                          | 역할                                                  | 비용 발생 가능성 | 비고                                           |
| ------------- | -------------------------------------- | --------------------------------------------------- | --------- | -------------------------------------------- |
| Network       | `aws_vpc.main`                         | AWS 내부에 독립적인 네트워크 영역을 생성합니다.                        | 낮음        | VPC 자체 비용은 일반적으로 발생하지 않습니다.                  |
| Network       | `aws_subnet.public_a`                  | Public Subnet A를 생성하여 외부 접근이 필요한 리소스를 배치할 수 있게 합니다. | 낮음        | Subnet 자체 비용은 없습니다.                          |
| Network       | `aws_subnet.public_c`                  | Public Subnet C를 생성하여 다중 AZ 구성을 고려합니다.              | 낮음        | ALB 구성 시 2개 이상의 AZ가 필요합니다.                   |
| Network       | `aws_subnet.private_a`                 | Private Subnet A를 생성하여 내부 리소스 배치 영역을 구성합니다.         | 낮음        | 현재 NAT Gateway는 제외합니다.                       |
| Network       | `aws_subnet.private_c`                 | Private Subnet C를 생성하여 내부망도 다중 AZ 구조로 설계합니다.        | 낮음        | 향후 DB 또는 내부 서버 확장 가능성을 고려합니다.                |
| Network       | `aws_internet_gateway.main`            | VPC가 인터넷과 통신할 수 있도록 Internet Gateway를 연결합니다.        | 낮음        | 자체 비용은 낮지만 데이터 전송 비용은 발생할 수 있습니다.            |
| Network       | `aws_route_table.public`               | Public Subnet의 인터넷 라우팅 경로를 정의합니다.                   | 낮음        | `0.0.0.0/0` 경로를 Internet Gateway로 보냅니다.      |
| Network       | `aws_route_table_association.public_a` | Public Subnet A에 Public Route Table을 연결합니다.         | 낮음        | Route Table은 연결되어야 실제 적용됩니다.                 |
| Network       | `aws_route_table_association.public_c` | Public Subnet C에 Public Route Table을 연결합니다.         | 낮음        | Public Subnet C도 인터넷 경로를 사용하게 합니다.           |
| Security      | `aws_security_group.bastion`           | Bastion EC2 접근을 제어하는 Security Group입니다.             | 낮음        | SSH 접근은 `allowed_ssh_cidr` 변수로 제한합니다.        |
| Security      | `aws_security_group.alb`               | ALB로 들어오는 HTTP 접근을 제어하는 Security Group입니다.          | 낮음        | 현재는 HTTP 80 포트를 기준으로 구성합니다.                  |
| Compute       | `aws_instance.bastion`                 | Bastion 또는 테스트용 EC2 인스턴스를 생성합니다.                    | 높음        | EC2는 실행 시간 기준 비용이 발생하므로 실습 후 destroy가 필요합니다. |
| Load Balancer | `aws_lb.main`                          | 외부 HTTP 요청을 받는 Application Load Balancer입니다.        | 높음        | ALB는 시간 기준 비용이 발생하므로 생성 후 바로 삭제합니다.          |
| Load Balancer | `aws_lb_target_group.main`             | ALB가 트래픽을 전달할 대상 그룹입니다.                             | 중간        | ALB와 함께 관리됩니다.                               |
| Load Balancer | `aws_lb_listener.http`                 | ALB의 HTTP 80 포트 요청 처리 규칙입니다.                        | 중간        | ALB 구성의 일부로 관리됩니다.                           |

## 5. 비용 관점 정리

현재 구성에서 비용 발생 가능성이 높은 리소스는 다음과 같습니다.

* `aws_instance.bastion`
* `aws_lb.main`
* `aws_lb_target_group.main`
* `aws_lb_listener.http`

VPC, Subnet, Internet Gateway, Route Table, Security Group은 자체 비용 부담이 낮은 편이지만, 연결된 리소스나 데이터 전송량에 따라 비용이 발생할 수 있습니다.

이 프로젝트에서는 비용 방지를 위해 다음 원칙을 적용합니다.

* 기본 작업은 `terraform plan`까지 수행합니다.
* 실제 생성이 필요한 경우에만 `terraform apply`를 실행합니다.
* 리소스 확인 후 즉시 `terraform destroy`를 수행합니다.
* NAT Gateway, RDS, EKS처럼 지속 과금 가능성이 큰 리소스는 현재 단계에서 제외합니다.

## 6. 현재 단계에서 apply를 생략하는 이유

현재 작업의 목적은 실제 서비스를 운영하는 것이 아니라, Terraform 코드로 AWS 인프라 구성을 정의하고 생성 예정 리소스를 검증하는 것입니다.

따라서 비용 발생 가능성이 있는 EC2와 ALB를 불필요하게 유지하지 않기 위해 `terraform apply`는 생략하고, `terraform validate`와 `terraform plan`을 통해 코드 구조와 생성 예정 리소스를 검증합니다.

