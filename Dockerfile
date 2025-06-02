FROM alpine:3.22.0@sha256:8a1f59ffb675680d47db6337b49d22281a139e9d709335b492be023728e11715

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
