ARG DISTRO=alpine
ARG DISTRO_VARIANT=3.17

FROM docker.io/tiredofit/${DISTRO}:${DISTRO_VARIANT}
LABEL maintainer="Dave Conroy (github.com/tiredofit)"

ARG RESTIC_VERSION
ARG RCLONE VERSION

ENV RESTIC_VERSION=v0.15.1 \
    RESTIC_REPO_URL=https://github.com/restic/restic \
    IMAGE_NAME="tiredofit/restic" \
    IMAGE_REPO_URL="https://github.com/tiredofit/restic/"

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
                    go \
                    git \
                    && \
    \
    package install .restic-run-deps \
                    coreutils \
                    fuse3 \
                    rclone \
                    tar \
                    && \
    \
    ln -s /usr/bin/fusermount3 /usr/sbin/fusemount && \
    \
    clone_git_repo "${RESTIC_REPO_URL}" "${RESTIC_VERSION}" && \
    go run build.go && \
    cp -R restic /usr/sbin/ && \
    \
    package remove .restic-build-deps && \
    package cleanup && \
    rm -rf /usr/src/*

COPY install /
