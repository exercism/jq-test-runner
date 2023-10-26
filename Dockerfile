FROM alpine:latest

# bash - v5.2.15-r6
# bats - v1.10.0-r0
RUN apk add --no-cache bash bats

# jq   - v1.7-r2
RUN apk add --no-cache --repository https://dl-cdn.alpinelinux.org/alpine/edge/main jq

WORKDIR /opt/test-runner
COPY . .
ENV BATS_RUN_SKIPPED=true
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
