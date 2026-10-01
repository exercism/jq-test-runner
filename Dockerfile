FROM alpine:3.24.2@sha256:294b683cb724975bec92580e1e685676bd4b50bda910ddb8c51d4cabeaec77e6

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
