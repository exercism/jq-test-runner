FROM alpine:3.18.4@sha256:eece025e432126ce23f223450a0326fbebde39cdf496a85d8c016293fc851978

# bash - v5.2.15-r5
# bats - v1.9.0-r0
RUN apk add --no-cache bash bats

# jq   - v1.7-r2
RUN apk add --no-cache --repository https://dl-cdn.alpinelinux.org/alpine/edge/main jq

WORKDIR /opt/test-runner
COPY . .
ENV BATS_RUN_SKIPPED=true
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
