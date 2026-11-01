FROM alpine:3.24.3@sha256:be2656061b536c1883c4034790e21d0a09c5aaaf51968b89368a3c0371ea2c9a

# $ docker run --rm -it alpine:3.24.2
# $ apk add --no-cache bash bats jq
# $ bash --version   # => GNU bash, version 5.3.9(1)-release (x86_64-alpine-linux-musl)
# $ bats --version   # => Bats 1.13.0
# $ jq --version     # => jq-1.8.2

RUN apk add --no-cache bash bats jq grep

WORKDIR /opt/test-runner
COPY . .
ENV BATS_RUN_SKIPPED=true
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
