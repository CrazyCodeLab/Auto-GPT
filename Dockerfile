# Use an official Python base image from the Docker Hub
FROM python:3.11-slim

# Install git
#这里的 bullseye 是指 Debian 11，如果你使用的是其他版本，需要将其替换为相应的版本号。
#sudo apt update
RUN cp /etc/apt/sources.list /etc/apt/sources.list.bak && \
sed -i 's#deb.debian.org#mirrors.aliyun.com#g' /etc/apt/sources.list && \
sed -i 's#security.debian.org#mirrors.aliyun.com#g' /etc/apt/sources.list && \
sed -i 's#http:#https:#g' /etc/apt/sources.list && \
apt-get -y update
RUN apt-get -y install git inetutils-ping curl wget vim nginx nodejs
RUN apt-get -y install chromium-driver
# 特殊安装 java
RUN echo "deb https://mirrors.aliyun.com/debian stretch main" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y openjdk-8-jdk && \
    sed -i '/stretch/d' /etc/apt/sources.list && \
    apt-get update

# Set environment variables
ENV PIP_NO_CACHE_DIR=yes \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# WORKDIR /app
# Create a non-root user and set permissions
# RUN useradd --create-home appuser
# WORKDIR /home/appuser
# RUN chown appuser:appuser /home/appuser
# USER appuser

# Copy the requirements.txt file and install the requirements
COPY requirements-docker.txt .
# COPY --chown=appuser:appuser requirements-docker.txt .
RUN pip install --no-cache-dir --user -r requirements-docker.txt -i https://mirrors.aliyun.com/pypi/simple/

# Copy the application files
# COPY --chown=appuser:appuser autogpt/ ./autogpt
COPY autogpt/ ./autogpt

# Set the entrypoint
ENTRYPOINT ["python", "-m", "autogpt", "--use-memory", "redis", "--gpt3only"]
# docker exec -it AutoGPT python -m autogpt --gpt3only
# docker run -it --name autogpt --env-file=./.env -v /f/docker/data/autogpt:/app/auto_gpt_workspace -e HTTP_PROXY=http://192.168.1.58:7890 -e HTTPS_PROXY=http://192.168.1.58:7890 autogpt:20230417
