
#!/usr/bin/env bash

MODS_FILE="modlist.txt"
LOG_FILE="install.log"

if [[ ! -f "$MODS_FILE" ]]; then
    echo "ERROR: $MODS_FILE not found."
    exit 1
fi

mapfile -t MODS < <(
    grep -vE '^[[:space:]]*(#|$)' "$MODS_FILE"
)

TOTAL=${#MODS[@]}
CURRENT=0
FAILED=()

echo "========================================"
echo " Packwiz Modrinth bulk installer"
echo " Mods: $TOTAL"
echo " Log:  $LOG_FILE"
echo "========================================"
echo

: > "$LOG_FILE"

for mod in "${MODS[@]}"; do
    CURRENT=$((CURRENT + 1))

    echo
    echo "========================================"
    echo "[$CURRENT/$TOTAL] Installing"
    echo "$mod"
    echo "========================================"

    {
        echo
        echo "========================================"
        echo "[$CURRENT/$TOTAL] $mod"
        echo "========================================"
    } >> "$LOG_FILE"

    # Automatically answer Y to dependency questions.
    if printf 'Y\n' | ./packwiz modrinth install "$mod" 2>&1 | tee -a "$LOG_FILE"; then
        echo
        echo "[OK] $mod"
    else
        STATUS=${PIPESTATUS[1]}

        echo
        echo "[FAILED] $mod (exit code $STATUS)"

        FAILED+=("$mod")
    fi
done

echo
echo "========================================"
echo " Installation finished"
echo "========================================"
echo "Total:  $TOTAL"
echo "Failed: ${#FAILED[@]}"
echo

if [[ ${#FAILED[@]} -gt 0 ]]; then
    echo "FAILED MODS:"
    for mod in "${FAILED[@]}"; do
        echo "  - $mod"
    done
else
    echo "All mods installed successfully."
fi

echo
echo "Full log: $LOG_FILE"
echo "========================================"
