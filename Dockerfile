FROM alpine:3.19.1@sha256:c5b1261d6d3e43071626931fc004f70149baeba2c8ec672bd4f27761f8e1ad6b

# bash - v5.2.15-r5
# bats - v1.9.0-r0
RUN apk add --no-cache bash bats

# jq   - v1.7-r2
RUN apk add --no-cache --repository https://dl-cdn.alpinelinux.org/alpine/edge/main jq

WORKDIR /opt/test-runner
COPY . .
ENV BATS_RUN_SKIPPED=true
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
