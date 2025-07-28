#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os          # 파일·디렉터리 조작 모듈
import csv         # CSV 읽기·쓰기를 위한 모듈
import argparse    # 커맨드라인 인자 파싱 모듈

def format_size(bytesize):
    """
    바이트 단위 숫자를 사람이 읽기 편한 문자열로 변환합니다.
    - 1024 단위로 나누며, 적절한 단위를 선택합니다.
    예: 2048 → '2.0KB', 1048576 → '1.0MB'
    """
    for unit in ['B', 'KB', 'MB', 'GB', 'TB']:
        # 현재 크기가 1024 미만이면 해당 단위를 사용
        if bytesize < 1024:
            return f"{bytesize:.1f}{unit}"
        bytesize /= 1024
    # TB 이상일 경우 PB 단위로 처리
    return f"{bytesize:.1f}PB"

def generate_report(target_dir, output_file):
    """
    주어진 디렉터리(target_dir)를 재귀적으로 순회하며 파일 정보를
    CSV(output_file)로 저장합니다.
    """
    # CSV 파일 열기: UTF-8, 개행 문제 방지
    with open(output_file, 'w', newline='', encoding='utf-8') as csvfile:
        writer = csv.writer(csvfile)
        # 헤더 행 작성
        writer.writerow(['파일 경로', '크기 (바이트)', '크기 (읽기용)'])
        
        # os.walk: 디렉터리 트리를 루트→자식 순으로 순회
        for root, dirs, files in os.walk(target_dir):
            for file in files:
                path = os.path.join(root, file)  # 전체 경로 생성
                try:
                    size = os.path.getsize(path)        # 바이트 단위 크기 조회
                    readable = format_size(size)        # 사람이 읽기 좋은 단위로 변환
                    # 행 쓰기: [경로, 바이트, 읽기용]
                    writer.writerow([path, size, readable])
                except Exception as e:
                    # 권한 문제 등 예외 발생 시 에러 표시
                    writer.writerow([path, 'ERROR', str(e)])
                    # (옵션) 로그 파일에 에러 기록을 남겨도 좋음

def main():
    """
    커맨드라인 인자를 처리하고, 유효성 검증 후 리포트 생성 함수를 호출합니다.
    """
    parser = argparse.ArgumentParser(
        description='디렉터리 내 파일 목록과 크기 리포트 생성기'
    )
    # 필수 인자: 디렉터리 경로
    parser.add_argument('directory',
                        help='리포트 생성 대상 디렉터리 경로')
    # 선택 인자: 출력 파일명 (기본: file_report.csv)
    parser.add_argument('-o', '--output',
                        default='file_report.csv',
                        help='생성할 CSV 파일명 (기본: file_report.csv)')
    args = parser.parse_args()

    # 인자로 받은 디렉터리가 실제 디렉터리인지 확인
    if not os.path.isdir(args.directory):
        print(f"오류: '{args.directory}'는 유효한 디렉터리가 아닙니다.")
        return

    # 리포트 생성
    generate_report(args.directory, args.output)
    print(f"✅ 리포트가 생성되었습니다: {args.output}")

if __name__ == '__main__':
    # 스크립트 직접 실행 시 main() 호출
    main()
