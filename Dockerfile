FROM alpine:3.19.0@sha256:51b67269f354137895d43f3b3d810bfacd3945438e94dc5ac55fdac340352f48

# bash - v5.2.15-r5
# bats - v1.9.0-r0
RUN apk add --no-cache bash bats

# jq   - v1.7-r2
RUN apk add --no-cache --repository https://dl-cdn.alpinelinux.org/alpine/edge/main jq

WORKDIR /opt/test-runner
COPY . .
ENV BATS_RUN_SKIPPED=true
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
