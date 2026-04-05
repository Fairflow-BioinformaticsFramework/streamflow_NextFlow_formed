# Esempio Streamflow — topX

Questa cartella contiene un esempio funzionante di workflow Streamflow generato da Baryon.

---

## File presenti e a cosa servono

| File | Chi lo genera | Scopo |
|---|---|---|
| `topx.yml` | Baryon | File principale: orchestrazione, deployment Docker |
| `topx.cwl` | Baryon | Definizione del processo: comando, input, output |
| `topx-params.yml` | Baryon | Valori concreti dei parametri per questa esecuzione |
| `annotated.csv` | Utente | File di dati da analizzare |

---

## `topx.yml` — il file principale

È il file che viene passato a `streamflow run`. Contiene tre sezioni:

- **`workflows`** — dice a Streamflow quale CWL eseguire e con quali parametri.
  - `file:` → nome del file `.cwl` nella stessa cartella
  - `settings:` → nome del file `-params.yml` nella stessa cartella
- **`bindings`** → collega il workflow al deployment Docker da usare
  - `step: /` → indica l'intero workflow (lasciare sempre `/`)
  - `target.model:` → deve corrispondere al nome in `models:`
- **`models`** — definisce il container Docker da usare
  - `type: docker` → sempre `docker` per immagini Docker Hub
  - `image:` → nome dell'immagine Docker, uguale a quello nel `.bala`

**Regola per Baryon:** il nome del file (`topx.yml`) è arbitrario ma per convenzione
usa il nome dell'applicazione. Cambia solo `image:` in base al `.bala`.

---

## `topx.cwl` — la definizione del processo

Descrive esattamente cosa viene eseguito dentro il container. Contiene:

- **`baseCommand`** — il comando base. Per script bash complessi usare sempre `[bash, -c]`
- **`arguments`** — i comandi bash da eseguire. Riferirsi agli input con `$(inputs.nomeInput)`
  e ai file con `$(inputs.nomeInput.path)`
- **`inputs`** — lista di tutti i parametri. Per ogni parametro specificare:
  - `type:` → `File` per file, `string` per testo, `int` per numeri interi, `float` per decimali
  - `default:` → valore di default (opzionale, non usare per i File)
  - `inputBinding.position:` → solo per i File, indica l'ordine come argomento posizionale
- **`outputs`** — file prodotti dal tool. Usare `File?` (con punto interrogativo) se il file
  potrebbe non essere prodotto. `glob:` indica il pattern per trovarlo nella work directory.

**Regola per Baryon:** gli `inputs` si ricavano dalle sezioni `[file]` e `[parameter]` del `.bala`.
Gli `outputs` si ricavano dalla sezione `[run]` o vanno definiti in base a cosa produce lo script.
I comandi in `arguments` si ricavano da `script=` e `usage=` del `[run]`.

---

## `topx-params.yml` — i parametri di input

Contiene i valori concreti da passare al workflow per questa specifica esecuzione.
Ogni voce deve corrispondere esattamente a un nome in `inputs:` del file `.cwl`.

- Per i **File**: usare sempre `class: File` + `path: ./nomeFile.ext`
  (il `./` indica che il file è nella stessa cartella)
- Per **stringhe**: valore diretto, es. `format: csv`
- Per **interi**: valore numerico senza virgolette, es. `threshold: 10`
- Per **booleani come stringa**: usare le virgolette, es. `logged: "FALSE"`

**Regola per Baryon:** i valori si ricavano da `value=` o dal primo valore di `values=`
nelle sezioni `[parameter]` del `.bala`. I file si ricavano dalle sezioni `[file]`.

---

## Come testare con WFRunner

1. Avvia WFRunner con `run.bat`
2. Apri il browser su `http://localhost:8082`
3. **Workflow file** → carica `topx.yml`
4. **Data files** → carica `topx.cwl` + `topx-params.yml` + `annotated.csv`
5. Clicca **Run Workflow**
6. A fine esecuzione scarica i risultati con **Download Results**

> ⚠️ Tutti i file devono stare nella stessa cartella quando li carichi.
> Il path `./annotated.csv` in `topx-params.yml` funziona perché WFRunner
> li copia tutti nella stessa directory prima di lanciare Streamflow.
