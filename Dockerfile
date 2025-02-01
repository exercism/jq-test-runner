FROM alpine:3.21.2@sha256:56fa17d2a7e7f168a043a2712e63aed1f8543aeafdcee47c58dcffe38ed51099

# $ docker run --rm -it alpine:3.21.2
# $ apk add --no-cache bash bats jq
# $ bash --version   # => GNU bash, version 5.2.37(1)-release
# $ bats --version   # => Bats 1.11.1
# $ jq --version     # => jq-1.7.1

RUN apk add --no-cache bash bats jq

WORKDIR /opt/test-runner
COPY . .
ENV BATS_RUN_SKIPPED=true
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
