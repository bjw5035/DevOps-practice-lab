# Terraform + Docker 로컬 실습 노트 (2026-08-11)

## 진행사항

- 목적: Terraform Docker provider로 로컬(eble)에서 apply/destroy 흐름을 직접 연습
- 방식: 코드를 AI가 대신 작성하지 않고 직접 작성 → 막히거나 틀린 부분만 짚어주는 방식으로 진행 (자세한 세팅은 [구성 방법](#구성-방법-환경-세팅) 참고)
- 현재 상태: `main.tf`의 리소스 3개(네트워크/이미지/컨테이너) 문법 작성 완료, 아직 `terraform init`/`apply` 실행 전 단계
- 업데이트: `terraform init` → `plan`까지 정상 검증 완료. 이번엔 `apply`/`destroy`는 진행하지 않기로 결정 (검증까지만으로 목적 달성 판단)
- 업데이트 2: Docker provider 리소스를 순서대로 익히는 걸로 방향 전환 — `docker_volume`(완료) → `env` 속성(진행 중, 오늘은 여기서 중단) → 컨테이너 2개 연결 → `healthcheck`/`restart_policy` 순으로 진행 예정

## 작성한 파일

- `terraform/docker-practice/provider.tf` — `kreuzwerker/docker` provider 선언
- `terraform/docker-practice/main.tf` — `docker_network`, `docker_image`, `docker_container` 리소스 (직접 작성 연습)
- `terraform/docker-practice/outputs.tf` — 접속 URL 출력

## 아키텍처

```
eble (로컬 서버)
│
└── Docker Daemon
    │
    ├── [기존] minikube 컨테이너 ── network: minikube
    │     (기존 k8s 실습 환경, 이번 작업과 완전히 분리되어 간섭 없음)
    │
    └── [신규] tf-practice-net (전용 브릿지 네트워크)
          └── tf-practice-family-photo 컨테이너
                image: jjwoos/devops-practice-lab:latest
                내부 포트 8000 → 호스트 포트 8080

terraform/docker-practice/  (AWS terraform과 분리된 별도 상태)
├── provider.tf   (kreuzwerker/docker provider 선언)
├── main.tf       (network → image → container 리소스, 의존순서대로 생성)
└── outputs.tf    (접속 URL http://localhost:8080 출력)
```

## 구성 방법 (환경 세팅)

1. **사전 조건 확인**: eble에 Docker 데몬이 이미 설치·실행 중인지 확인 (minikube 컨테이너가 이미 이 데몬을 쓰고 있는 걸로 확인됨)
2. **Terraform 실행 방식**: eble에 terraform 바이너리를 직접 설치하지 않고, `hashicorp/terraform` Docker 이미지로 실행 (기존 AWS terraform 작업 때와 동일한 방식)
3. **디렉토리 분리**: `terraform/docker-practice/`를 새로 만들어 기존 AWS terraform 프로젝트와 상태 파일(state)을 완전히 분리
4. **네트워크/포트 충돌 확인**: `docker network ls`, `ss -tlnp`로 기존 minikube 네트워크·사용 중인 포트 확인 후, 안 겹치는 네트워크 이름(`tf-practice-net`)과 포트(8080)로 결정
5. **provider 선언**: `provider.tf`에 `kreuzwerker/docker` provider 선언 → `terraform init` 시 해당 provider 플러그인 다운로드
6. **리소스 정의 순서**: 네트워크(`docker_network`) → 이미지(`docker_image`, pull) → 컨테이너(`docker_container`, 앞의 둘을 참조해 네트워크 연결 + 포트 매핑)

## 개념 설명 (실습 중 헷갈렸던 부분)

### 1. `resource` 블록의 두 자리 이름
```hcl
resource "<고정된_타입>" "<내가_짓는_별명>" {
  ...
}
```
- 첫 번째 자리(타입)는 provider 문서(Terraform Registry)에 정해진 고정값 — 마음대로 지을 수 없음
- 두 번째 자리(별명)는 이 설정 파일 안에서만 쓰는 자유 이름. 문법상 콜론(`:`) 등은 사용 불가

### 2. 리소스 간 참조
```hcl
image = docker_image.devops-practice-lab.image_id
```
- `<타입>.<별명>.<속성>` 형태로 다른 리소스의 결과값을 가져옴
- 참조 표현은 따옴표로 감싸면 안 됨 (감싸면 그냥 문자열이 되어버림)
- 이 참조 덕분에 Terraform이 리소스 간 생성 순서(의존성)를 자동으로 판단함

### 3. Terraform 안의 이름 vs 실제 세상의 이름
- Terraform 리소스의 별명(로컬 이름)은 실제 Docker Hub 등 외부 시스템과 아무 관계 없는, 설정 파일 안에서만 통하는 이름
- 반면 속성값(`name`, `image` 등)은 실제로 외부 시스템에서 찾아야 하는 진짜 식별자여야 함
- 예: `jjwoos/devops-practice-lab:latest`에서 `jjwoos`는 Docker Hub 계정(namespace), 이게 빠지면 공식 이미지 저장소(`library/`)에서 찾으려다 실패함

### 4. 같은 개념, 다른 속성 이름
- `docker_image` 리소스(타입 자체가 "이미지") → 이미지 경로를 지정하는 속성명은 `name`
- `docker_container` 리소스 → 어떤 이미지를 쓸지 지정하는 속성명은 `image`
- 개념은 같지만(이미지 지정) provider가 리소스마다 다르게 정의해둔 것이라 외울 수밖에 없고, 헷갈릴 때마다 Registry의 Argument Reference를 확인하는 습관이 필요함

### 5. 네트워크 연결 블록
- 컨테이너를 특정 네트워크에 붙이는 블록은 `network_data`(❌, 이건 읽기 전용 계산값 확인용)가 아니라 `networks_advanced`(⭕)

### 6. 포트 매핑
- k8s manifest의 `nodePort`(외부 노출용)와 컨테이너가 실제로 리스닝하는 `containerPort`는 다른 값 — Docker provider의 `ports.internal`에는 컨테이너가 실제로 듣는 포트(이 프로젝트 기준 8000)를 넣어야 함

### 7. 블록(Block) vs 속성(Argument) 문법 구분
- `이름 = 값` (속성, `=` 있음) 과 `이름 { ... }` (블록, `=` 없음)은 완전히 다른 문법
- Registry 문서에서 그 항목이 **(String)/(Number)/(List of String)/(Map of String)** 등으로 표시되면 속성(`=` 사용), **(Block Set)/(Block List)**로 표시되면 블록(`{}`만 사용)
- 예: `docker_container`의 `ports`/`networks_advanced`/`volumes`는 (Block Set) → `{}`, `env`는 (List of String) → `=`
- 이건 provider가 정의한 스키마 타입에 달려있어서 외울 게 아니라 문서에서 그때그때 타입 표시를 확인하는 게 정답

## 자주 헷갈렸던 실수 목록

- 타입 자리에 별명을 넣음 (`resource "tf-practice-net" "tf-practice-net"`)
- 별명에 콜론을 포함시킴 (`"devops-practice-lab:latest"`)
- 참조 표현을 따옴표로 감싸 문자열로 만들어버림
- 리소스가 자기 자신을 참조하는 순환 구조를 만듦
- `docker_image`와 `docker_container`의 속성명(`name` vs `image`)을 서로 바꿔 씀
- k8s의 nodePort와 컨테이너의 실제 리스닝 포트를 혼동함
- 블록 이름 오타/혼동 (`network_data` vs `networks_advanced`, `protocal` vs `protocol`)

## 참고 방법

- Terraform Registry(registry.terraform.io) → provider 검색(`kreuzwerker/docker`) → Resources 탭에서 각 리소스의 **Example Usage**, **Argument Reference**, **Attributes Reference** 확인하는 것이 기본 워크플로

## 다음에 할 일

- `terraform/docker-practice/main.tf` 문법 완성 후 `terraform init` → `plan` → `apply`로 실제 컨테이너 기동 확인
- 접속 확인 후 `terraform destroy`로 정리
- (보류) 필요해지면 위 `apply` → 접속 확인 → `destroy` 이어서 진행
- `docker_container`에 `env` 속성 작성 이어서 진행 (오늘 중단 지점)
- 이후 순서대로: 컨테이너 2개 연결(네트워크로 통신) → `healthcheck`/`restart_policy` nested block 연습
