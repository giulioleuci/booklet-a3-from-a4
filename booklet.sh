#!/bin/bash
# ============================================================
# booklet.sh — Imposizione booklet A4→A3, pagine tutte dritte
# Uso: ./booklet.sh input.pdf [output.pdf]
# Stampa fronte/retro con: orientamento ORIZZONTALE
#                          rilegatura LATO CORTO (short edge)
# ============================================================
set -e

INPUT="${1:?Errore: specifica il file PDF di input}"
OUTPUT="${2:-$(basename "${INPUT%.pdf}")_booklet.pdf}"

check_dep() {
    command -v "$1" &>/dev/null || { echo "Errore: installa con: sudo apt install $2"; exit 1; }
}
check_dep pdfjam  texlive-extra-utils
check_dep pdfinfo poppler-utils
check_dep python3 python3

# ---------- Conta le pagine ----------
ORIG_N=$(pdfinfo "$INPUT" | awk '/^Pages:/{print $2}')
echo "Pagine originali: $ORIG_N"

# ---------- Calcola ordine pagine ----------
# Booklet senza rotazione (short-edge flip):
#   foglio k → fronte [N-2k, 2k+1] | retro [2k+2, N-2k-1]
PAGE_PAIRS=$(python3 - "$ORIG_N" <<'PYEOF'
import sys
orig = int(sys.argv[1])
n = orig + (4 - orig % 4) % 4   # arrotonda al multiplo di 4
pairs = []
for k in range(n // 4):
    fl = n - 2*k        # front-left
    fr = 2*k + 1        # front-right
    bl = 2*k + 2        # back-left
    br = n - 2*k - 1    # back-right
    def pg(p): return str(p) if p <= orig else '{}'
    pairs.append(f"{pg(fl)},{pg(fr)}")   # fronte
    pairs.append(f"{pg(bl)},{pg(br)}")   # retro
print('\n'.join(pairs))
PYEOF
)

echo "Facciate da generare:"
echo "$PAGE_PAIRS"
echo ""

# ---------- Crea una PDF per ogni facciata ----------
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

FACES=()
i=0
while IFS= read -r PAIR; do
    FACE="$TMPDIR/face_$(printf '%03d' $i).pdf"
    pdfjam "$INPUT" "$PAIR" \
        --nup 2x1 \
        --paper a3paper \
        --landscape \
        --noautoscale false \
        --outfile "$FACE" 2>/dev/null
    FACES+=("$FACE")
    ((i++)) || true
done <<< "$PAGE_PAIRS"

# ---------- Unisci tutto ----------
pdfjam "${FACES[@]}" \
    --paper a3paper \
    --landscape \
    --outfile "$OUTPUT" 2>/dev/null

echo "✓ File creato: $OUTPUT"
echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║  IMPOSTAZIONI DI STAMPA                          ║"
echo "║  • Fronte/retro: SÌ                              ║"
echo "║  • Orientamento: ORIZZONTALE (landscape)         ║"
echo "║  • Rilegatura:   LATO CORTO  (flip short edge)   ║"
echo "║  • Poi piega a metà → quadernetto pronto!        ║"
echo "╚══════════════════════════════════════════════════╝"
