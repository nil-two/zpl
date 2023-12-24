#!/usr/bin/env bats

cmd=$BATS_TEST_DIRNAME/../zpl
tmpdir=$BATS_TEST_DIRNAME/../tmp
stdout=$BATS_TEST_DIRNAME/../tmp/stdout
stderr=$BATS_TEST_DIRNAME/../tmp/stderr
exitcode=$BATS_TEST_DIRNAME/../tmp/exitcode

setup() {
  mkdir -p -- "$tmpdir"
}

teardown() {
  rm -rf -- "$tmpdir"
}

check() {
  printf "%s\n" "" > "$stdout"
  printf "%s\n" "" > "$stderr"
  printf "%s\n" "0" > "$exitcode"
  "$@" > "$stdout" 2> "$stderr" || printf "%s\n" "$?" > "$exitcode"
}

@test 'zpl: print stdin as is if no arguments passed' {
  src=$(printf "%s\n" $'
  ABC
  DEF
  100
  200
  ' | sed -e '1d' -e 's/^  //')
  dst=$(printf "%s\n" $'
  ABC
  DEF
  100
  200
  ' | sed -e '1d' -e 's/^  //')
  check "$cmd" <<< "$src"
  [[ $(cat "$exitcode") == 0 ]]
  [[ $(cat "$stdout") == $dst ]]
}

@test 'zpl: print stdin as is if 1 file passed' {
  src=$(printf "%s\n" $'
  ABC
  DEF
  100
  200
  ' | sed -e '1d' -e 's/^  //')
  dst=$(printf "%s\n" $'
  ABC
  DEF
  100
  200
  ' | sed -e '1d' -e 's/^  //')
  check "$cmd" <(printf "%s\n" "$src")
  [[ $(cat "$exitcode") == 0 ]]
  [[ $(cat "$stdout") == $dst ]]
}

@test 'zpl: print zipped lines if 2 file passed' {
  src1=$(printf "%s\n" $'
  ABC
  DEF
  ' | sed -e '1d' -e 's/^  //')
  src2=$(printf "%s\n" $'
  100
  200
  ' | sed -e '1d' -e 's/^  //')
  dst=$(printf "%s\n" $'
  ABC
  100
  DEF
  200
  ' | sed -e '1d' -e 's/^  //')
  check "$cmd" <(printf "%s\n" "$src1") <(printf "%s\n" "$src2")
  [[ $(cat "$exitcode") == 0 ]]
  [[ $(cat "$stdout") == $dst ]]
}

@test 'zpl: fill missing lines with blank lines if the number of lines are different' {
  src1=$(printf "%s\n" $'
  ABC
  ' | sed -e '1d' -e 's/^  //')
  src2=$(printf "%s\n" $'
  100
  200
  ' | sed -e '1d' -e 's/^  //')
  src3=$(printf "%s\n" $'
  XXX
  YYY
  ZZZ
  ' | sed -e '1d' -e 's/^  //')
  dst=$(printf "%s\n" $'
  ABC
  100
  XXX

  200
  YYY


  ZZZ
  ' | sed -e '1d' -e 's/^  //')
  check "$cmd" <(printf "%s\n" "$src1") <(printf "%s\n" "$src2") <(printf "%s\n" "$src3")
  [[ $(cat "$exitcode") == 0 ]]
  [[ $(cat "$stdout") == $dst ]]
}

@test 'zpl: fill missing lines with blank lines even if some files are empty' {
  src1=$(printf "%s\n" $'
  ABC
  DEF
  GHI
  ' | sed -e '1d' -e 's/^  //')
  src2=''
  dst=$(printf "%s\n" $'
  ABC

  DEF

  GHI

  ' | sed -e '1d' -e 's/^  //')
  check "$cmd" <(printf "%s\n" "$src1") <(printf "%s\n" "$src2")
  [[ $(cat "$exitcode") == 0 ]]
  [[ $(cat "$stdout") == $dst ]]
}

@test 'zpl: separate argf if -s passed' {
  src=$(printf "%s\n" $'
  ABC
  DEF
  ---
  100
  200
  ---
  XXX
  YYY
  ' | sed -e '1d' -e 's/^  //')
  dst=$(printf "%s\n" $'
  ABC
  100
  XXX
  DEF
  200
  YYY
  ' | sed -e '1d' -e 's/^  //')
  check "$cmd" -s--- <(printf "%s\n" "$src")
  [[ $(cat "$exitcode") == 0 ]]
  [[ $(cat "$stdout") == $dst ]]
}

@test 'zpl: separate argf if --separator passed' {
  src=$(printf "%s\n" $'
  ABC
  DEF
  ---
  100
  200
  ---
  XXX
  YYY
  ' | sed -e '1d' -e 's/^  //')
  dst=$(printf "%s\n" $'
  ABC
  100
  XXX
  DEF
  200
  YYY
  ' | sed -e '1d' -e 's/^  //')
  check "$cmd" --separator=--- <(printf "%s\n" "$src")
  [[ $(cat "$exitcode") == 0 ]]
  [[ $(cat "$stdout") == $dst ]]
}

@test 'zpl: treat sep as a file separator when -s passed' {
  src1=$(printf "%s\n" $'
  ABC
  DEF
  GHI
  ---
  100
  200
  ' | sed -e '1d' -e 's/^  //')
  src2=$(printf "%s\n" $'
  XXX
  ' | sed -e '1d' -e 's/^  //')
  dst=$(printf "%s\n" $'
  ABC
  100
  XXX
  DEF
  200

  GHI


  ' | sed -e '1d' -e 's/^  //')
  check "$cmd" -s--- <(printf "%s\n" "$src1") <(printf "%s\n" "$src2")
  [[ $(cat "$exitcode") == 0 ]]
  [[ $(cat "$stdout") == $dst ]]
}

@test 'zpl: print usage if --help passed' {
  check "$cmd" --help
  [[ $(cat "$exitcode") == 0 ]]
  [[ $(cat "$stdout") =~ ^"usage: zpl" ]]
}

@test 'zpl: print error if nonexistent file passed' {
  check "$cmd" ctcE4_S_c4IsW5JZaxtuaahC7sLb1cWGT9lslCRn
  [[ $(cat "$exitcode") == 1 ]]
  [[ $(cat "$stderr") =~ ^'zpl: Can'"'"'t open' ]]
}

@test 'zpl: print error if unkown option passed' {
  check "$cmd" --test
  [[ $(cat "$exitcode") == 1 ]]
  [[ $(cat "$stderr") =~ ^'zpl: Unknown option' ]]
}

# vim: ft=bash
