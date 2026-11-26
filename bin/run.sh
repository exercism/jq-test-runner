#!/usr/bin/env bash
# shellcheck disable=SC2164,SC2103

# Arguments:
# $1: exercise slug
# $2: path to solution directory
# $3: path to output directory
#
# Example:
# ./run.sh two-fer path/to/two-fer path/to/output/directory
# ./run.sh two-fer twofer output
#
# First runs the tests with bats and saves the TAP output,
# then parses that TAP file to produce the JSON file.

# the version of the test-runner interface:
# https://exercism.org/docs/building/tooling/test-runners/interface
INTERFACE_VERSION=3

main() {
    echo "Running exercise tests for JQ"

    local slug="$1"
    echo "Test slug: ${slug}"

    local solution_dir
    solution_dir="$(realpath "$2")"
    echo "Solution directory: ${solution_dir}"

    local output_dir
    output_dir="$(realpath "$3")"
    echo "Output directory: ${output_dir}"

    local output_file="$output_dir/results.out"
    local json_result_file="$output_dir/results.json"

    local -A test_bodies    # populated in get_test_bodies
    local -A task_ids       # populated in get_test_bodies

    run_tests "$slug" "$solution_dir" "$output_file"
    build_report "$output_file" "$json_result_file"
}

run_tests() {
    # Run tests and pipe output to results.out file.

    local slug="$1"
    local solution_dir="$2"
    local output_file="$3"

    echo "Running tests."

    cd "$solution_dir"

    local test_file
    if [[ -f .meta/config.json ]]; then
        # production test runner
        test_file=$(jq -r '.files.test[0]' .meta/config.json)
    elif [[ -f .exercism/config.json ]]; then
        # local testing
        test_file=$(jq -r '.files.test[0]' .exercism/config.json)
    else
        test_file="test-${slug}.bats"
    fi

    echo "Test output:"

    bats --tap "$test_file" 2>&1 | tee "$output_file" || true

    get_test_bodies "$test_file"

    echo "Test run ended. Output saved in $output_file"

    cd -
}

get_test_bodies() {
    local test_file=$1
    local name line indent task_id
    local state="out"
    local body=()
    test_bodies=()
    task_ids=()

    local start_test_re='^@test ['\''"](.+)['\''"] \{[[:blank:]]*$'
    local end_test_re='^\}[[:blank:]]*$'

    while IFS= read -r line; do
        case "$state" in
            out)
                if [[ $line =~ $start_test_re ]]; then
                    name=${BASH_REMATCH[1]}
                    body=()
                    state="in"
                    unset task_id
                fi
                ;;
            in)
                if [[ $line =~ $end_test_re ]]; then
                    test_bodies["$name"]=$(printf '%s\n' "${body[@]}")
                    if [[ -v task_id ]]; then
                        task_ids["$name"]=$task_id
                    fi
                    state="out"
                elif [[ $line == *BATS_RUN_SKIPPED*skip* ]]; then
                    # skip the skips
                    continue
                elif ((${#body[@]} == 0)) && [[ $line == *([[:blank:]]) ]]; then
                    # ignore blank lines at the top of the test body
                    continue
                elif [[ $line =~ "## task "([0-9]+) ]]; then
                    task_id=${BASH_REMATCH[1]}
                else
                    # We want to unindent the body: find the indentation of the first line.
                    ((${#body[@]} == 0)) && indent=${line%%[^[:blank:]]*}

                    body+=("${line#"$indent"}")
                fi
                ;;
        esac
    done < "$test_file"
}

build_report() {
    # Parse results.out and write result to results.json

    local output_file="$1"
    local json_result_file="$2"

    echo "Producing JSON report."

    readarray -t output < "$output_file"

    # first line in TAP output should be test plan: `1..10`
    if [[ ! ${output[0]} =~ ^([0-9]+)\.\.([0-9]+)$ ]]; then
        error "$output_file" "$json_result_file"
        return 1
    fi

    local first_test="${BASH_REMATCH[1]}"
    local last_test="${BASH_REMATCH[2]}"
    local test_count=$((last_test - first_test + 1))

    echo "Tried to run $test_count tests according to TAP plan."

    # process the rest of the TAP output
    local status="pass"
    local test_body failed test_name

    # `results` is a flat array that holds 6 elements for each test, in order:
    #   1. the test name
    #   2. the status, "pass" or "fail"
    #   3. the test code (the body of the @test block)
    #   4. the error message (empty if the test passed)
    #   5. the debug output (empty if there was none)
    #   6. the task id (empty if the test has no "## task" comment)
    # So test 1 is results[0..5], test 2 is results[6..11], and so on.
    # print_report turns each chunk of 6 into one test object.
    local results=()
    local error_message 
    local debug_output prev_debug_output

    # with debug output, we get
    # - lines starting with '# ["DEBUG:",`
    # - the test result 'not ok' or 'ok'
    # - error output starting with '# '
    #
    # The error output from test N abuts the debug output from test N+1

    for ((i = 1; i < ${#output[@]}; i++)); do
        if [[ ${output[i]} =~ '# '('["DEBUG:",'.*) ]]; then
            debug_output+="${BASH_REMATCH[1]}"$'\n'

        elif [[ ${output[i]} =~ ^"# "(.*) ]]; then
            error_message+="${BASH_REMATCH[1]}"$'\n'

        elif [[ ${output[i]} =~ ^(not )?ok\ [0-9]+\ (.*)$ ]]; then
            # start of new test
            # add _previous_ to results
            if [[ -n $test_name ]]; then
                if [[ -z $failed ]]; then
                    results+=("$test_name" pass "$test_body" "" "$prev_debug_output" "${task_ids[$test_name]:-}")
                else
                    status="fail"
                    results+=("$test_name" fail "$test_body" "$error_message" "$prev_debug_output" "${task_ids[$test_name]:-}")
                fi
            fi

            failed=${BASH_REMATCH[1]}
            test_name=${BASH_REMATCH[2]}
            test_body=${test_bodies[$test_name]:-}
            error_message=""
            prev_debug_output=$debug_output
            debug_output=""
        fi
    done

    # last test
    if [[ -n $test_name ]]; then
        if [[ -z $failed ]]; then
            results+=("$test_name" pass "$test_body" "" "$prev_debug_output" "${task_ids[$test_name]:-}")
        else
            status="fail"
            results+=("$test_name" fail "$test_body" "$error_message" "$prev_debug_output" "${task_ids[$test_name]:-}")
        fi
    fi

    print_report "$status" "${results[@]}" > "$json_result_file"

    echo "Wrote report to $json_result_file"

    return 0
}

error() {
    # Store entire output to results.json file, in case of an error.

    local output_file="$1"
    local json_result_file="$2"

    echo "Failed to parse output."
    echo "This probably means there was an error running the tests."

    jq  --null-input \
        --argjson version "$INTERFACE_VERSION" \
        --arg status "error" \
        --arg message "$(< "$output_file")" \
        '{version: $version, status: $status, message: $message}'

    echo "Wrote error report to $json_result_file"
}

print_report() {
    # Print the complete result JSON, given the overall status and the
    # `results` array from build_report (6 elements per test).
    #
    # The elements reach jq through `--args`, so jq sees them as the array
    # $ARGS.positional, called $f below. `range(0; $f | length; 6)` gives the
    # index of the first element of each test (0, 6, 12, ...), and for each
    # index $i jq builds one test object from $f[$i] to $f[$i + 5]:
    #   $f[$i]      name
    #   $f[$i + 1]  status
    #   $f[$i + 2]  test_code
    #   $f[$i + 3]  message, added only if the test failed
    #   $f[$i + 4]  output, added only if it is not empty
    #   $f[$i + 5]  task_id, added only if it is not empty
    # The `[ ... ]` around this collects the objects into the "tests" array.
    #
    # Building every test object in this one jq call is faster than starting
    # jq once per test.
    local status=$1
    shift
    jq  --null-input \
        --argjson version "$INTERFACE_VERSION" \
        --argjson tools "$(tool_versions)" \
        --arg status "$status" \
        '{
            version: $version,
            status: $status,
            "test-environment": $tools,
            tests: [
                $ARGS.positional as $f
                | range(0; $f | length; 6) as $i
                | {name: $f[$i], status: $f[$i + 1], test_code: $f[$i + 2]}
                + if $f[$i + 1] == "fail" then {message: $f[$i + 3]} else {} end
                + if $f[$i + 4] != "" then {output: $f[$i + 4]} else {} end
                + if $f[$i + 5] != "" then {task_id: $f[$i + 5]} else {} end
            ]
        }' \
        --args -- "$@"
}

tool_versions() {
    # print versions of tools in the test environment
    jq  --null-input \
        --arg jq "$(jq --version)" \
        --arg bats "$(bats --version)" \
        --arg OS "$(
                # probably don't need this complexity, but ...
                if [[ -f /etc/lsb-release ]]; then
                    . /etc/lsb-release; echo "$DISTRIB_DESCRIPTION"
                elif command -v uname >/dev/null; then
                    uname -sro
                else
                    echo "Doesn't look like Linux..."
                fi
            )" \
        '$ARGS.named'
}    # ' for syntax highlighting

main "$@"
