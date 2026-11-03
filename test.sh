echo "--- valid programs (should say OK) ---"
for f in tests/valid/*.mpl
do
    echo -n "$f: "
    ./mpl < $f
done

echo "--- invalid programs (should give an error) ---"
for f in tests/invalid/*.mpl
do
    echo -n "$f: "
    ./mpl < $f
done
