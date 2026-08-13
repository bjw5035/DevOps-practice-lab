# 아카이브: VPC + ALB + Bastion 구조 (예전 작업)

**작업 시기**: 2026-05-11 ~ 2026-06-03
**아카이브 처리일**: 2026-08-13
**현재 상태**: AWS에 실제로 적용된 것 없음 (`terraform state list` 결과 비어있음 — 한 번도 apply 안 됐거나, apply 후 destroy까지 완료된 상태)

## 왜 아카이브했나

2026-08-11에 방향을 새로 정했음: family-photo-service를 **EC2 하나만 최소로** 배포하기로 결정 (ALB/NAT Gateway/RDS는 비용 문제로 생략). 이 폴더의 구조(VPC + 퍼블릭/프라이빗 서브넷 + ALB + bastion EC2)는 그 이전 단계에서 만든 것이라, 새 방향과 안 맞아서 분리함.

새 작업은 `terraform/aws-ec2-minimal-deploy/`에서 진행 중.

## 파일 구분

**핵심 코드 (최신 버전, 실제로 쓰던 것)**
- `provider.tf`, `network.tf`, `security.tf`, `compute.tf`, `load_balancer.tf`, `locals.tf`, `variables.tf`, `versions.tf`, `outputs.tf`

**백업 파일 (핵심 코드의 예전 스냅샷, 참고용)**
- `main.tf.original` (2026-05-27) — 가장 오래된 초기 버전
- `main.tf.bak` (2026-05-29) — 그 다음 버전
- `terraform.tfstate.backup` (2026-05-24) — state 백업본

**작업 중 만든 문서**
- `PLAN_ANALYSIS.md`, `PLAN_RESULT.txt`, `RESOURCE_OVERVIEW.md` (모두 2026-06-03) — 당시 `terraform plan` 결과 분석/정리
- `terraform-check.sh` (2026-06-03) — 점검용 스크립트

**설정값**
- `terraform.tfvars` (2026-05-21), `terraform.tfvars.example` (2026-06-03)

**Terraform 내부 파일 (건드릴 필요 없음)**
- `.terraform/`, `.terraform.lock.hcl` (2026-05-11 — provider 최초 설치 시점)
- `terraform.tfstate` (2026-05-24 — 현재 비어있음)
