[2026-05-19]
Phase 2 SG 설계 진행 (ingress 1개, egress 검토 중)
내일 : SG 코드 작성 + apply
걸린 부분 : 학습 진도가 느림

===========================================================================

## 2026-08-11

### CI/CD 파이프라인 점검
- `deploy.yml` 수정사항 실제 반영 여부 확인 완료
  - family-photo-service 저장소 checkout, build context 변경, kubectl apply + rollout restart 추가 → 이미 GitHub에 커밋/push 되어 있음 확인
  - k8s Deployment(`kubernetes/family-photo-service.yaml`)도 이미지가 `jjwoos/devops-practice-lab:latest`, `imagePullPolicy: Always`로 되어 있음 확인
  - **TODO**: 실제 eble 클러스터에 이 상태가 반영됐는지는 아직 미확인
```bash
    k get deployment family-photo-service -o jsonpath='{.spec.template.spec.containers[0].image}'
```

### 저장소 정리
- 예전 실습용 k8s yaml 폴더 이름 변경: `kubernetes/family-photo-kubernates` → `kubernetes/archive-family-photo-kubernates`

### 새 방향 결정: Terraform + AWS 실배포
- Terraform으로 AWS에 family-photo-service 실제 배포 → 확인 → 즉시 destroy (지속 운영 의도 없음, 비용 방지)
- eble에 Terraform 직접 설치 안 함 → Docker 컨테이너로 Terraform 실행
- 최소 구성: EC2 단일 인스턴스 + Docker로 앱 직접 실행 (ALB/NAT Gateway/RDS 생략)
- 시작 전 체크리스트:
  1. Billing Alert 설정 (진행 중)
  2. IAM 사용자 생성 (루트 계정 미사용)
  3. AWS CLI / access key 발급

### 작업 관리
- Notion "🧮 TO-DO 관리" DB로 작업 항목 관리 시작
  - CI/CD 이미지 eble 실제 반영 확인 (보통 / 시작 전)
  - AWS 사용 준비 (높음 / 진행 중)
  - Terraform으로 EC2 배포 → destroy (높음 / 시작 전)

### Terraform Docker provider 로컬 실습
- eble 로컬에서 Terraform `kreuzwerker/docker` provider로 컨테이너 apply/destroy 흐름 연습
- `terraform/docker-practice/`에 격리된 환경 구성 (기존 minikube·AWS terraform state와 분리) — 상세 아키텍처/구성 방법/개념 정리는 [terraform-docker-practice-notes.md](terraform-docker-practice-notes.md) 참고
- 코드는 직접 작성하며 문법 연습 (resource 타입/별명 구분, 리소스 간 참조, provider별 속성명 차이 등)
- `terraform init` → `plan`까지 정상 검증 완료. 이번엔 `apply`/`destroy`는 진행하지 않기로 결정 (검증까지만으로 목적 달성 판단)
- 오늘 안에 Docker provider 리소스 전반을 순서대로 익히기로 함: `docker_volume` → `env` 속성 → 컨테이너 2개 연결 → `healthcheck`/`restart_policy`
- `docker_volume` 리소스 작성 + `docker_container`의 `volumes` 블록으로 연결까지 완료 (직접 작성, 참조 문법 정확히 적용)
- `env` 속성 작성 중간에 오늘 실습 종료 — 상세 개념 정리는 [terraform-docker-practice-notes.md](terraform-docker-practice-notes.md) 참고

