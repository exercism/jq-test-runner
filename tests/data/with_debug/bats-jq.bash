#!/usr/bin/env bash
#
# `bats-core` will take both stdout and stderr to be the `run` command's output.
# However `jq` prints its DEBUG output on stderr.
# This function redirects jq's stderr to a process substitution:
# - lines starting with '["DEBUG:"' will be prefixed with a hash and printed on
#   file descriptor 3
# - other lines on stderr will remain on stderr for bats to consume.
#
# See `bats-core` docs:
# - "Printing to the terminal", https://bats-core.readthedocs.io/en/stable/writing-tests.html#printing-to-the-terminal
# - "File descriptor 3", https://bats-core.readthedocs.io/en/stable/writing-tests.html#file-descriptor-3-read-this-if-bats-hangs


jq() {
    command jq "$@" 2> >(
        while IFS= read -r line; do
            if [[ $line == '["DEBUG:",'* ]]; then
                echo "# $line" >&3
            else
                echo "$line" >&2
            fi
        done
    )
}
