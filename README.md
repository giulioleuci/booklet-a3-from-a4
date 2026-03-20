# booklet.sh

Script bash per l'imposizione tipografica di un PDF A4 in un quadernetto stampabile su A3 fronte/retro.

## Come funziona

Lo script riordina le pagine del PDF di input in modo che, una volta stampato fronte/retro su fogli A3 in orizzontale e piegati a metà, le pagine risultino nell'ordine corretto — esattamente come un quadernetto rilegato al centro.

Per un PDF di 4 pagine, ad esempio, il risultato è:

```
FRONTE A3:  [ pag. 4 ] [ pag. 1 ]
RETRO  A3:  [ pag. 2 ] [ pag. 3 ]
                 ↓ piega al centro
         → quadernetto: 1 | 2 | 3 | 4 ✓
```

Il numero di pagine del PDF di input deve essere un multiplo di 4. Se non lo è, lo script aggiunge automaticamente pagine bianche in coda.

## Dipendenze

```bash
sudo apt install texlive-extra-utils poppler-utils python3
```

| Strumento  | Pacchetto               | Utilizzo                              |
|------------|-------------------------|---------------------------------------|
| `pdfjam`   | `texlive-extra-utils`   | composizione e unione delle facciate  |
| `pdfinfo`  | `poppler-utils`         | conteggio delle pagine del PDF        |
| `python3`  | `python3`               | calcolo dell'ordine delle pagine      |

## Utilizzo

```bash
chmod +x booklet.sh
./booklet.sh input.pdf [output.pdf]
```

Se `output.pdf` non viene specificato, il file di output viene salvato nella stessa cartella dell'input con il suffisso `_booklet`.

### Esempi

```bash
# Output automatico → relazione_booklet.pdf
./booklet.sh relazione.pdf

# Output con nome personalizzato
./booklet.sh relazione.pdf stampa_finale.pdf
```

## Impostazioni di stampa

Una volta ottenuto il PDF, impostare la stampante come segue:

| Parametro       | Valore                          |
|-----------------|---------------------------------|
| Fronte/retro    | **Sì**                          |
| Orientamento    | **Orizzontale** (landscape)     |
| Rilegatura      | **Lato corto** (flip short edge)|
| Formato carta   | **A3**                          |

Piegare ogni foglio a metà lungo il lato corto: le pagine risulteranno nell'ordine corretto.

## Note tecniche

Lo script **non usa** l'opzione `--booklet` di `pdfjam`, che ruota di 180° le pagine esterne assumendo una rilegatura sul lato lungo. Invece, compone manualmente ogni facciata senza alcuna rotazione, compatibilmente con la modalità **flip on short edge** delle stampanti standard.

## Requisiti di sistema

- Linux (testato su Ubuntu 24)
- Bash ≥ 4
- Python 3

## Licenza

Distribuito sotto licenza **GNU General Public License v3.0 o successiva**.
Vedere il testo completo della licenza su: <https://www.gnu.org/licenses/gpl-3.0.html>

## Crediti

Generato con **Claude Sonnet 4.6 Extended** (Anthropic).
