#!/bin/bash

# Manual test for stree.

function run {
    set -x
    .build/release/stree $@
    { set +x; } 2>/dev/null
}

rm -fr test/

mkdir test/
touch test/file
touch test/.hidden_file
mkdir test/dir/
mkdir test/.hidden_dir/
touch test/dir/file
touch test/dir/.hidden_file
mkdir test/dir/dir/
mkdir test/dir/.hidden_dir/

make build

run --version
run --help
run test/
run -a test/
run -L 0 test/
run -L 1 test/
run -L 2 test/
run -a -L 0 test/
run -a -L 1 test/
run -a -L 2 test/
run -s test/
run -s -L 0 test/
run --help -s test/

make clean
rm -r test/
