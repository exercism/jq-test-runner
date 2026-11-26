# Debian (glibc) replaces Alpine (musl) because bats spends most of each test
# in bash, and bash allocates memory constantly. musl's malloc and free took
# about 60% of musl's share of the run, and glibc's allocator is much faster,
# so bats runs each test about a third faster here.
#
# $ docker run --rm -it --entrypoint bash exercism/jq-test-runner
# $ bash --version   # => GNU bash, version 5.2.37(1)-release (x86_64-pc-linux-gnu)
# $ bats --version   # => Bats 1.13.0
# $ jq --version     # => jq-1.8.2

# Debian's packages are older than Alpine's (jq 1.7.1, bats 1.11), so this
# stage fetches the same jq and bats releases that Alpine 3.24 ships.
FROM debian:trixie-slim@sha256:8aa5a7bf5a1955bddbe7d74fcdd0b91ab30e74362a8b73af672b0481b35b44a0 AS tools

ARG TARGETARCH
ADD --checksum=sha256:a85e12b8828271a152b338ca8109aa23493b57950987c8e6dff97ba492772ff3 \
    https://github.com/bats-core/bats-core/archive/refs/tags/v1.13.0.tar.gz /tmp/bats.tar.gz
ADD --chmod=755 --checksum=sha256:b1c22172dd303f3be49e935aa56aa48a8b7a46e0bc838b4997d3bb451495870f \
    https://github.com/jqlang/jq/releases/download/jq-1.8.2/jq-linux-amd64 /tmp/jq-amd64
ADD --chmod=755 --checksum=sha256:8b85c817833814ddca00a144c33705546355afccf0cf39b188f3cdb48b852309 \
    https://github.com/jqlang/jq/releases/download/jq-1.8.2/jq-linux-arm64 /tmp/jq-arm64
RUN mkdir /tmp/bats \
 && tar -xzf /tmp/bats.tar.gz -C /tmp/bats --strip-components=1 \
 && /tmp/bats/install.sh /opt/bats \
 && mv "/tmp/jq-${TARGETARCH}" /opt/jq

FROM debian:trixie-slim@sha256:8aa5a7bf5a1955bddbe7d74fcdd0b91ab30e74362a8b73af672b0481b35b44a0

COPY --from=tools /opt/bats /usr/local
COPY --from=tools /opt/jq /usr/local/bin/jq

WORKDIR /opt/test-runner
COPY . .
ENV BATS_RUN_SKIPPED=true
ENTRYPOINT ["/opt/test-runner/bin/run.sh"]
