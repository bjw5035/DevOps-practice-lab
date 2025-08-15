# Docker 이미지에 Git 설치를 위한 DockerFile 실습
FROM ubuntu:latest
LABEL authors="send2"

RUN apt update && apt install -y git

ENTRYPOINT ["/bin/bash", "-c", "sleep 3600"]