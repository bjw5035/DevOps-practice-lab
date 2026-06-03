# Terraform Plan Analysis

## 1. 목적

이 문서는 Terraform plan 결과를 기준으로 생성 예정 리소스를 분석하기 위한 문서입니다.

현재 프로젝트는 AWS 기본 인프라를 Terraform 코드로 정의하고 있으며, 실제 apply 전 plan 결과를 통해 어떤 리소스가 생성될지 검토합니다.

## 2. Plan 결과 요약

```text
Plan: 15 to add, 0 to change, 0 to destroy.
