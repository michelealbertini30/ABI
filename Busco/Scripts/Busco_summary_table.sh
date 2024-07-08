#!/bin/bash

echo -e "BUSCO SUMMARY TABLE\n\n--------------------------------------------------------" > Busco_summary.table
echo -e "Complete BUSCOs (C)\n Complete and single-copy BUSCOs (S)\n Complete and duplicated BUSCOs (D)\n Fragmented BUSCOs (F)\n Missing BUSCOs (M)\n Total BUSCO groups searched (n)" >> Busco_summary.table
echo "--------------------------------------------------------" >> Busco_summary.table
grep "C:" ./*.busco/*.txt | sed 's/\.busco.*\.txt//' | sed 's/,/\t/g' >> Busco_summary.table
