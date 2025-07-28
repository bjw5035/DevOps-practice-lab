#!/usr/bin/env python3

import argparse
import re
from collections import Counter

def count_patterns_in_file(path, patterns):
    """
    파일을 한 줄씩 읽어, patterns 리스트에 있는 각 패턴이
    몇 번 등장하는지 세어서 Counter 형태로 반환합니다.
    """
    counts = Counter({p: 0 for p in patterns})
    with open(path, 'r', encoding='utf-8', errors='ignore') as f:
        for line in f:
            for pat in patterns:
                # 대소문자 구분 없이 찾으려면 re.IGNORECASE 옵션 추가 가능
                if re.search(pat, line):
                    counts[pat] += 1
    return counts

def main():
    # 1) 인자 정의
    parser = argparse.ArgumentParser(description='로그 파일에서 ERROR/WARNING 키워드 발생 횟수 집계')
    parser.add_argument('logfile', help='분석할 로그 파일 경로')
    parser.add_argument('-p', '--pattern', action='append', default=['ERROR', 'WARNING'], help='찾을 키워드 (기본: ERROR, WARNING). 여러번 지정 가능')
    args = parser.parse_args()

    # 2) 키워드 집계
    counts = count_patterns_in_file(args.logfile, args.pattern)

    # 3) 결과 출력
    print(f"=== '{args.logfile}' 분석 결과 ===")
    for pat in args.pattern:
        print(f"   {pat}: {counts[pat]}건")

if __name__ == '__main__':
    main()