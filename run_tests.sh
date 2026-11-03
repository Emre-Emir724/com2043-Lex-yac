#!/bin/sh
# Every file in tests/valid must print OK; every file in tests/invalid must not.
pass=0; fail=0
for f in tests/valid/*.mpl; do
  out=$(./mpl < "$f" 2>&1)
  if [ "$out" = "OK" ]; then pass=$((pass+1)); echo "PASS  $f"
  else fail=$((fail+1)); echo "FAIL  $f (expected OK)"; echo "$out" | sed 's/^/      /'; fi
done
for f in tests/invalid/*.mpl; do
  out=$(./mpl < "$f" 2>&1)
  if [ "$out" != "OK" ]; then pass=$((pass+1)); echo "PASS  $f -> $out"
  else fail=$((fail+1)); echo "FAIL  $f (expected a syntax error)"; fi
done
echo "$pass passed, $fail failed"
[ $fail -eq 0 ]
