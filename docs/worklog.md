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

===========================================================================

## 2026-08-12

### Terraform Docker provider 로컬 실습 이어서
- `docker_container`에 `env` 속성 완성: `env = ["API_KEY=dev-key"]`
  - `API_KEY`는 family-photo-service(`app/auth.py`)가 `X-API-Key` 헤더 검증에 쓰는 유일한 앱 레벨 환경변수 (Dockerfile 기본값 `dev-key`)
- `terraform plan` 무에러 확인
- 커밋: `feat: docker_container env 속성 추가 (API_KEY)` (직접 커밋 진행)
- 다음 단계 방향 결정: 두 번째 `docker_image`/`docker_container` 리소스를 새로 추가해서 같은 네트워크(`tf-practice-net`)에 붙여 컨테이너 2개 통신 확인 → 작업 완료/중단 시 `destroy`로 정리, 필요할 때 다시 `apply`로 재현
- **다음에 이어할 지점**: 두 번째 컨테이너용 `docker_image`/`docker_container` 리소스 작성 시작 전 (이미지 미정)

### 기타
- `kubectl get pods -n <ns> -A` 처럼 `-n`과 `-A`(all-namespaces)를 같이 쓰면 `-A`가 우선 적용돼 전체 네임스페이스가 나온다는 점 확인 (원하는 네임스페이스만 보려면 `-A` 빼야 함)

===========================================================================

## 2026-08-13

### CI/CD 이미지 eble 실제 반영 확인 (완료)
- `kubectl get deployment family-photo-service -o jsonpath='{.spec.template.spec.containers[0].image}'` 실행
- 결과: `jjwoos/devops-practice-lab:latest` → `deploy.yml` 커밋 내용과 실제 클러스터 상태 일치 확인
- 2026-08-11에 남겨뒀던 TODO 완료 처리

### AWS 실배포 사전 체크리스트 완료
- `aws sts get-caller-identity`로 확인: 로컬 AWS CLI가 `terraform-user` IAM 사용자로 이미 구성되어 있음 확인 (Account: 282772004523)
- Billing Alert 설정 완료 (Claude 브라우저로 콘솔에서 진행)
- IAM 사용자 확인 완료 (Claude 브라우저로 진행)
- 2026-08-11 체크리스트 3항목(Billing Alert / IAM 사용자 생성 / AWS CLI·access key) 모두 완료 → "Terraform으로 EC2 배포 → destroy" 실습 시작 가능한 상태

### docker-practice: 컨테이너 2개 네트워크 연결 (완료)
- `main.tf`에 `docker_image`/`docker_container` 리소스로 nginx, redis 추가, 기존 `devops-practice-lab`과 함께 `tf-practice-net`에 연결 (직접 작성, 오타/포트 문제 확인하며 진행)
- `terraform fmt`, `plan` 문제없이 통과 → `terraform apply`로 실제 컨테이너 3개(devops-practice-lab/nginx/redis) 기동 확인 (nginx 8081, redis 6379, devops-practice-lab 8080)
- 확인 후 `terraform destroy`로 리소스 8개(컨테이너 3 + 이미지 3 + 네트워크 1 + 볼륨 1) 정리, minikube 컨테이너는 영향 없음 확인
- 실습 중 나온 개념 설명(provider별 시스템 격리, state가 디렉토리 단위로 독립적인 이유, docker provider로 만든 컨테이너가 k8s에 안 보이는 이유 등)은 Notion "🟢 Terraform 입문" 위키 페이지에 반영
- 로컬에 terraform 바이너리(`/usr/bin/terraform` v1.15.8)가 설치되어 있는 것 확인 — 기존에 기록해둔 "Docker 컨테이너로 terraform 실행" 방식과 다르게, 지금은 로컬 설치본으로 직접 실행 중인 것으로 보임 (전환 시점 미확인)

### terraform/ 디렉토리 재구성
- 예전 VPC+ALB+Bastion 구조(2026-05~06월 작업분)를 `terraform/archive-aws-vpc-alb-bastion/`으로 이동, 상태/날짜/백업여부 정리한 README.md 추가
- 새 실습용 `terraform/aws-ec2-minimal-deploy/` 디렉토리 신설 (ALB/NAT/RDS 생략, EC2 하나만 최소 구성)

### 보안: 공개 저장소에 노출된 집 공인 IP 제거
- `terraform/PLAN_RESULT.txt`, `terraform.tfstate`(과거 커밋), `.github/workflows/deploy.yml`(과거 커밋)에 집 공인 IP가 평문으로 남아있던 것 발견 (2026-06-03 커밋부터 약 2개월간 public GitHub 저장소에 노출)
- `git filter-repo --replace-text`로 전체 히스토리(74개 커밋)에서 해당 IP를 `0.0.0.0`으로 치환 → `git push --force`로 반영 완료, 확인 결과 현재 `main`/`git log`/`git clone` 어디에도 안 남아있음
- `.gitignore`에 `PLAN_RESULT.txt` 등 terraform 명령어 결과 덤프 패턴 추가해 재발 방지
- Notion "🔴 Terraform 고급" 위키에 사고 사례로 정리, TO-DO DB에 후속 대응(다른 곳에 clone된 게 있으면 재동기화 필요) 항목 추가

### aws-ec2-minimal-deploy: VPC 네트워킹 작성 시작
- `network.tf`에 `aws_vpc` → `aws_subnet`(public, `map_public_ip_on_launch = true`) → `aws_internet_gateway` → `aws_route_table`(0.0.0.0/0 → IGW route 포함)까지 직접 작성 (오타/누락 확인하며 진행: 태그 `Name` 대문자, subnet에 `availability_zone`/`map_public_ip_on_launch` 누락, IGW 리소스 자체 누락 등)
- Notion "🌐 VPC 기본 구조" 위키에 VPC→Subnet→IGW→RouteTable 개념을 "신도시 개발" 비유로 정리해 추가
- **다음에 이어할 지점**: `aws_route_table_association`으로 서브넷-라우팅테이블 연결 아직 안 함, `provider.tf`도 아직 빈 파일 — 이 둘만 하면 network.tf 마무리, 이후 security.tf → compute.tf → outputs.tf 순서
