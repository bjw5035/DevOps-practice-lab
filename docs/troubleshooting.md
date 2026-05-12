# 트러블슈팅 노트

## 1. Terraform `.terraform` 폴더가 GitHub 100MB 제한 걸린 사건

**작업일:** 2026-05-11

### 1) 상황 (Situation)
AWS VPC생성을 위한 Terraform작업을 진행 후 완료한 폴더를 GitHub에 Push를 진행하는 와중에
100MB 제한이 걸려 작업물이 일부만 올라간 상황 발생

### 2) 에러 (Error)
remote: error: File terraform/.terraform/providers/.../terraform-provider-aws_v5.100.0_x5 
        is 674.20 MB; this exceeds GitHub's file size limit of 100.00 MB
remote: error: GH001: Large files detected.
! [remote rejected] main -> main (pre-receive hook declined)

### 3) 원인 분석 (Root Cause)
작업 데이터 용량이 허용치를 초과함

### 4) 해결 과정 (Solution)

1. .gitignore 파일 추가 -> .gitignore 작성앞으로 들어올 파일 차단
2. git rm -r --cached terraform/.terraform -> 이미 commit된 파일을 git에서 빼기 (디스크는 유지)
3. git commit --amend --no-edit -> 이전 commit을 큰 파일 빠진 버전으로 갈아엎기4git push100MB 제한 통과, 정상 업로드

### 5) 배운 점 (Lessons Learned)
- Terraform 프로젝트 시작 시 제일 처음 만들어야 하는것은 main.tf파일 인것 같다.
