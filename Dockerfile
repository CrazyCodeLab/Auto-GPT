# Use an official Python base image from the Docker Hub
FROM python:3.10-slim

# Install git
#这里的 bullseye 是指 Debian 11，如果你使用的是其他版本，需要将其替换为相应的版本号。
# 设置时区
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
#sudo apt update
    cp /etc/apt/sources.list /etc/apt/sources.list.bak && \
    sed -i 's#deb.debian.org#mirrors.aliyun.com#g' /etc/apt/sources.list && \
    sed -i 's#security.debian.org#mirrors.aliyun.com#g' /etc/apt/sources.list && \
    sed -i 's#http:#https:#g' /etc/apt/sources.list && \
    apt-get -y update && \
    apt-get -y install git inetutils-ping curl wget vim nginx nodejs && \
    apt-get -y install chromium-driver

# Install Xvfb and other dependencies for headless browser testing
RUN apt-get update \
    && apt-get install -y wget gnupg2 libgtk-3-0 libdbus-glib-1-2 dbus-x11 xvfb ca-certificates

# Install Firefox / Chromium
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update \
    && apt-get install -y chromium firefox-esr

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
COPY requirements.txt .
# COPY --chown=appuser:appuser requirements.txt .
RUN sed -i '/Items below this point will not be included in the Docker Image/,$d' requirements.txt && \
	pip install --no-cache-dir --user -r requirements.txt

# Copy the application files
# COPY --chown=appuser:appuser autogpt/ ./autogpt
COPY autogpt/ ./autogpt

# Set the entrypoint
ENTRYPOINT ["python", "-m", "autogpt", "--use-memory", "redis", "--gpt3only"]
# docker exec -it AutoGPT python -m autogpt --gpt3only
# docker run -it --name autogpt --env-file=./.env -v /f/docker/data/autogpt:/auto_gpt_workspace -e HTTP_PROXY=http://192.168.1.58:7890 -e HTTPS_PROXY=http://192.168.1.58:7890 autogpt:20230420
