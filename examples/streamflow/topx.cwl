#!/usr/bin/env cwl-runner
# Versione CWL utilizzata. Usare sempre v1.2.
cwlVersion: v1.2

# class: CommandLineTool indica che questo file descrive un singolo comando da eseguire.
class: CommandLineTool

# baseCommand: il comando base da eseguire nel container.
# [bash, -c] significa "esegui uno script bash inline".
baseCommand: [bash, -c]

# arguments: lista dei comandi bash da eseguire dentro il container.
# Tutti i riferimenti agli input si fanno con $(inputs.nomeparametro).
# Per i File usare $(inputs.nomeparametro.path) per ottenere il percorso.
# shellQuote: false è necessario per permettere l'uso di && e altri operatori shell.
arguments:
  - valueFrom: |
      cp $(inputs.annotated_matrix.path) /data/annotated.$(inputs.format) &&
      Rscript /bin/top.R annotated $(inputs.format) $(inputs.separator) $(inputs.logged) $(inputs.threshold) $(inputs.type) &&
      cp /data/*_gene_expression_distribution.pdf output.pdf 2>/dev/null || true &&
      cp /data/filtered_* filtered_output.txt 2>/dev/null || true
    shellQuote: false

# inputs: definisce tutti i parametri di input del tool.
# Ogni input ha un nome, un tipo e opzionalmente un valore di default.
inputs:

  # Input di tipo File: il file di dati da analizzare.
  # inputBinding position: 0 lo passa come primo argomento posizionale al comando.
  annotated_matrix:
    type: File
    inputBinding:
      position: 0

  # Input di tipo string: formato del file di input (es. csv, tsv).
  format:
    type: string
    default: csv

  # Input di tipo string: separatore usato nel file (es. virgola, tab).
  separator:
    type: string
    default: ","

  # Input di tipo string: se i dati sono in scala logaritmica (TRUE o FALSE).
  logged:
    type: string
    default: "FALSE"

  # Input di tipo int: soglia numerica per il filtraggio.
  threshold:
    type: int
    default: 10

  # Input di tipo string: tipo di analisi da eseguire.
  type:
    type: string
    default: expression

# outputs: definisce i file prodotti dal tool.
# type: File? significa che il file è opzionale (potrebbe non essere prodotto).
# glob: pattern per trovare il file di output nella directory di lavoro.
outputs:

  gene_pdf:
    type: File?
    outputBinding:
      glob: output.pdf

  filtered:
    type: File?
    outputBinding:
      glob: filtered_output.txt
