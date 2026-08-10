## CI/CD 통합 작업 (진행 예정)

- 문제: CI가 docker/Dockerfile(git 연습용 더미)을 빌드 중, family-photo-service 앱과 무관
- family-photo-service는 별도 Git 저장소 (~/projects/family-photo-service, app/main.py 존재)
- 결정: DevOps-practice-lab 안으로 코드 통합하는 방향으로 진행 예정
  - family-photo-service 코드를 lab 저장소 안 폴더로 이동
  - CI의 build context 경로를 그 폴더로 수정
  - Deployment는 임시로 로컬 이미지(family-photo-service0.1.1:latest, Never)로 되돌려놓은 상태