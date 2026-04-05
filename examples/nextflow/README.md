# Esempio Nextflow — topX

Questa cartella contiene un esempio funzionante di workflow Nextflow generato da Baryon.

## File presenti

- `topx.nf` — il workflow Nextflow generato da Baryon (NON deve contenere il blocco `docker {}`)
- `nextflow.config` — configurazione Docker di default, da distribuire insieme al `.nf`
- `annotated.csv` — file di dati di esempio

## Note per chi genera il .nf con Baryon

Il file `.nf` **non deve contenere** il blocco:
```
docker {
    enabled = true
    ...
}
```
Questo va nel `nextflow.config` separato, che è sempre uguale e lo trovi già pronto qui.
Chi usa Nextflow professionalmente può personalizzare il `nextflow.config`; chi non lo carica, ci pensa il WFRunner da solo.

## Come testare con WFRunner

1. Avvia WFRunner con `run.bat`
2. Apri il browser su `http://localhost:8082`
3. **Workflow file** → carica `topx.nf`
4. **Data files** → carica `annotated.csv` (il `nextflow.config` è opzionale, il server lo genera in automatico se non lo carichi)
5. Clicca **Run Workflow**
6. A fine esecuzione scarica i risultati con **Download Results**

## PER BARON COSA VUOL DIRE? 
Praticamente baryon dovrà generare il file nf e poi generare anche il file di config che sarà sempre uguale, quindi genererà o uno zip o entrambi i file, come vuoi 
