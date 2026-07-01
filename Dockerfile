FROM alpine:3.24.1@sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b

# $ docker run --rm -it alpine:3.24.1
# $ apk add --no-cache bash bats jq
# $ bash --version   # => GNU bash, version 5.3.9(1)-release (x86_64-alpine-linux-musl)
# $ bats --version   # => Bats 1.13.0
# $ jq --version     # => jq-1.8.1

RUN apk add --no-cache bash bats jq grep

WORKDIR /opt/test-runner
COPY . .
ENV BATS_RUN_SKIPPED=true
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
