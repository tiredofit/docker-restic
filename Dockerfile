ARG DISTRO=alpine
ARG DISTRO_VARIANT=3.21-6.5.18

FROM docker.io/tiredofit/nginx:${DISTRO}-${DISTRO_VARIANT}
LABEL maintainer="Dave Conroy (github.com/tiredofit)"

ARG RESTIC_VERSION
ARG RESTIC_REST_SERVER_VERSION
ARG R_CLONE_VERSION

ENV RESTIC_VERSION=${RESTIC_VERSION:-"v0.18.0"} \
    RESTIC_REST_SERVER_VERSION=${RESTIC_REST_SERVER_VERSION:-"v0.13.0"} \
    RESTIC_REPO_URL=${RESTIC_REPO_URL:-"https://github.com/restic/restic"} \
    RESTIC_REST_SERVER_REPO_URL=${RESTIC_REST_SERVER_REPO_URL:-"https://github.com/restic/rest-server"} \
    R_CLONE_VERSION=${R_CLONE_VERSION:-"v1.70.3"} \
    R_CLONE_REPO_URL=${R_CLONE_REPO_URL:-"https://github.com/rclone/rclone"} \
    NGINX_CLIENT_BODY_BUFFER_SIZE=20M \
    NGINX_SITE_ENABLED="restic-rest-server" \
    NGINX_ENABLE_CREATE_SAMPLE_HTML=FALSE \
    NGINX_WORKER_PROCESSES=1 \
    IMAGE_NAME="tiredofit/restic" \
    IMAGE_REPO_URL="https://github.com/tiredofit/docker-restic/"

RUN source assets/functions/00-container && \
    set -x && \
    addgroup -S -g 10000 restic && \
    adduser -D -S -s /sbin/nologin \
            -h /dev/null \
            -G restic \
            -g "restic" \
            -u 10000 restic \
            && \
    \
    package update && \
    package upgrade && \
    package install .restic-build-deps \
                    binutils \
                    go \
                    git \
                    && \
    \
    package install .restic-run-deps \
                    apache2-utils \
                    coreutils \
                    fuse3 \
                    s-nail \
                    tar \
                    && \
    \
    ln -s /usr/bin/fusermount3 /usr/sbin/fusermount && \
    \
    clone_git_repo "${RESTIC_REPO_URL}" "${RESTIC_VERSION}" && \
    go run build.go && \
    strip restic && \
    cp -R restic /usr/sbin/ && \
    \
    clone_git_repo "${RESTIC_REST_SERVER_REPO_URL}" "${RESTIC_REST_SERVER_VERSION}" && \
    go run build.go && \
    strip rest-server && \
    cp rest-server /usr/sbin && \
    \
    clone_git_repo "${R_CLONE_REPO_URL}" "${R_CLONE_VERSION}" && \
    go build rclone.go && \
    strip rclone && \
    cp rclone /usr/sbin && \
    \
    package remove .restic-build-deps && \
    package cleanup && \
    rm -rf \
           /root/.cache \
           /root/go \
           /usr/src/*

COPY install /
