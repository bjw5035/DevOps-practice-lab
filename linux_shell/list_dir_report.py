#!/usr/bin/env python3

import os
import csv
import argparse

def format_size(bytesize):

    for unit in ['B','KB','MB','GB','TB']:
        if bytesize < 1024:
            return f"{bytesize:.1f}{unit}" 
        bytesize /= 1024
        return f"{bytesize:.1f}PB"

def generate_report(target_dir, output_file):
    with open(output_file, 'w', newline='', encoding='utf-8') as csvfile:
            writer = csv.writer(csvfile)

            writer.writerow(['path', 'bite', 'read'])

            for root, dirs, files in os.walk(target_dir):
                for file in files:
                    path = os.path.join(root, file)
                    try:
                        size = os.path.getsize(path)
                        readable = format_size(size)
                        writer.writerow([path, size, readable])
                    except Exception as e:
                        writer.writerow([path, 'ERROR', str(e)])

def main():
    parser = argparse.ArgumentParser(
        description='디렉터리 내 파일 목록과 크기 리포트 생성기'
    )
    parser.add_argument('directory', help='리포트 생성 대상 디렉터리 경로')
    parser.add_argument('-o', '--output', default='file_report.csv', help='생성할 CSV 파일명 (기본: file_report.csv)')
    args = parser.parse_args()

    if not os.path.isdir(args.directory):
        print(f"오류: '{args.directory}'는 유효한 디렉터리가 아닙니다.")
        return

    generate_report(args.directory, args.output)
    print(f" 리포트가 생성되었습니다: {args.output}")

if __name__ == '__main__':
    main()
