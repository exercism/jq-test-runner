FROM alpine:3.21.3@sha256:a8560b36e8b8210634f77d9f7f9efd7ffa463e380b75e2e74aff4511df3ef88c

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
