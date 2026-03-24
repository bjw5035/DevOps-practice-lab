# 🛠️ DevOps Practice Lab

> 미니PC(Ubuntu) 홈랩 환경에서 구축한 DevOps 실습 환경입니다.  
> Linux 서버 운영, Kubernetes, Docker, CI/CD 파이프라인, 모니터링까지 직접 구성하며 학습합니다.

![Last Commit](https://img.shields.io/github/last-commit/bjw5035/DevOps-practice-lab)

---

## 📐 전체 아키텍처
```
[ GitHub ] ──push──▶ [ GitHub Actions CI/CD ]
                              │
                              ▼
                     [ Docker Build & Push ]
                              │
                              ▼
              [ Minikube (Ubuntu 미니PC 홈랩) ]
              ┌──────────────────────────────┐
              │  Pod │ Service │ Ingress      │
              │  ConfigMap │ Secret           │
              └──────────────────────────────┘
```

---

## 📁 디렉토리 구조

- `.github/workflows` : GitHub Actions CI/CD 파이프라인
- `docker` : docker-compose 및 컨테이너 관리 스크립트
- `kubernetes` : Deployment, Service, Ingress, ConfigMap, Secret 매니페스트
- `linux_shell` : 리소스 모니터링 및 로그 분석 스크립트

---

## 🔧 주요 실습 내용

### 1. CI/CD 파이프라인 (GitHub Actions)
- `main` 브랜치 push 시 자동 빌드 트리거
- Docker 이미지 빌드 및 푸시

### 2. Kubernetes (Minikube on Ubuntu)
- Deployment, Service, Ingress 구성
- ConfigMap / Secret 환경변수 관리
- Replica 구성을 통한 무중단 배포 실습

### 3. Docker
- docker-compose 멀티 컨테이너 환경 구성

### 4. Linux Shell Script
- 서버 리소스(CPU, Memory, Disk) 자동 점검
- 로그 분석 및 운영 지표 산출 (grep, awk, tail 활용)
- 실무 기반: LGU+ 기업서비스 운영팀 모니터링 패턴 적용

---

## 🚀 실행 방법

### Kubernetes 매니페스트 적용
```bash
kubectl apply -f kubernetes/
kubectl get pods -w
```

### Docker Compose 실행
```bash
cd docker
docker-compose up -d
```

### 리소스 모니터링 스크립트
```bash
chmod +x linux_shell/resource_monitor.sh
./linux_shell/resource_monitor.sh
```

---

## 🛠️ 기술 스택

| 분류 | 기술 |
|------|------|
| Container | Docker, docker-compose |
| Orchestration | Kubernetes (Minikube) |
| CI/CD | GitHub Actions |
| Monitoring | Grafana, Prometheus |
| IaC (예정) | Terraform |
| OS | Ubuntu 22.04 (미니PC 홈랩) |
| Script | Shell Script, Python |

---

## 📅 업데이트 계획

- [ ] Terraform으로 AWS VPC/EC2/ALB 인프라 코드화
- [ ] ArgoCD GitOps 구성 추가
- [ ] Prometheus + Grafana 대시보드 추가

---

## 📬 Contact

- Blog: https://send.tistory.com/
- Email: send2ugfd@naver.com
