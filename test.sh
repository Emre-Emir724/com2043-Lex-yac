echo "--- valid programs (should say OK) ---"
for f in tests/valid/*.mpl
do
    printf "%s: " "$f"
    ./mpl < $f
done

echo "--- invalid programs (should give an error) ---"
for f in tests/invalid/*.mpl
do
    printf "%s: " "$f"
    ./mpl < $f
done
