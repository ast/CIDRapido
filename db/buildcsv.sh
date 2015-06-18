#!/bin/bash
set -e

#wget -q -SN http://www.datasus.gov.br/cid10/V2008/downloads/CID10CSV.zip
#unzip -o CID10CSV.zip

#for file in *.CSV
#do
#    iconv -f iso-8859-1 -t utf8 "$file" >"$file.new" &&
#    mv -f "$file.new" "$file"
#done

# Parse all files into one big

# en-us
cut --output-delimiter=";" -b 7-14,78- icd10cm_order_2014.txt|awk -F ";" '{gsub(/ /, "", $1); print $1 ";"  $2}' > all_en-us.csv

# pt-br
awk -F ";" 'NR > 1 {i = index($4,"-"); print "cap;" $2 ";" $3 ";" NR-1 ";" substr($4,i+2)}' CID-10-CAPITULOS.CSV > all_pt-br.csv
awk -F ";" 'NR > 1 {print "grp;" $1 ";" $2 ";" NR-1 ";" $3 }' CID-10-GRUPOS.CSV >> all_pt-br.csv
awk -F ";" 'NR > 1 {print "cat;" $1 ";;" NR-1 ";" $3}' CID-10-CATEGORIAS.CSV >> all_pt-br.csv
awk -F ";" 'NR > 1 {print "sub;" $1 ";;" NR-1 ";" $5}' CID-10-SUBCATEGORIAS.CSV >> all_pt-br.csv
