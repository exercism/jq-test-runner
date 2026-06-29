FROM alpine:3.23.5@sha256:fd791d74b68913cbb027c6546007b3f0d3bc45125f797758156952bc2d6daf40

# $ docker run --rm -it alpine:3.23.2
# $ apk add --no-cache bash bats jq
# $ bash --version   # => GNU bash, version 5.3.3(1)-release (x86_64-alpine-linux-musl)
# $ bats --version   # => Bats 1.13.0
# $ jq --version     # => jq-1.8.1

RUN apk add --no-cache bash bats jq grep

WORKDIR /opt/test-runner
COPY . .
ENV BATS_RUN_SKIPPED=true
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
