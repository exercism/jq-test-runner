FROM alpine:3.22.2@sha256:4b7ce07002c69e8f3d704a9c5d6fd3053be500b7f1c69fc0d80990c2ad8dd412

# $ docker run --rm -it alpine:3.22.0
# $ apk add --no-cache bash bats jq
# $ bash --version   # => GNU bash, version 5.2.37(1)-release
# $ bats --version   # => Bats 1.12.0
# $ jq --version     # => jq-1.8.0

RUN apk add --no-cache bash bats jq

WORKDIR /opt/test-runner
COPY . .
ENV BATS_RUN_SKIPPED=true
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
