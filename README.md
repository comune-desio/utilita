# Utilità

Questo repository contiene un insieme di script di varia utilità.

## Conversione da .csv a .geojson

Uso:

```
ruby csv2geojson.rb <filename.csv>
```

Crea il file `filename.geojson` nella directory corrente.

Il file .csv in input deve essere dotato delle seguenti colonne:

- latitude
- longitude
- name
- TOPONIMO
- INDIRIZZO
- CIVICO
- DESCRIZIONE
