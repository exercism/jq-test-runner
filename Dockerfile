FROM alpine:3.23.2@sha256:865b95f46d98cf867a156fe4a135ad3fe50d2056aa3f25ed31662dff6da4eb62

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
