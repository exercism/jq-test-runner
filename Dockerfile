FROM alpine:3.10

RUN apk add --no-cache jq # coreutils

WORKDIR /opt/test-runner
COPY . .
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
