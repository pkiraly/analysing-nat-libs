#!/usr/bin/env bash

rm ungvary-counts.csv

echo "1/12) LEADER 06 versus LEADER 07"
php collocations-count.php leader06_typeOfRecord_ss leader07_bibliographicLevel_ss ldr06-ldr07 >> ungvary-counts.csv
echo "2/12) LEADER 06 versus LEADER 17"
php collocations-count.php leader06_typeOfRecord_ss leader17_encodingLevel_ss ldr06-ldr17 >> ungvary-counts.csv
echo "3/12) LEADER 07 versus LEADER 17"
php collocations-count.php leader07_bibliographicLevel_ss leader17_encodingLevel_ss ldr07-ldr17 >> ungvary-counts.csv
echo "4/12) LEADER 06 versus 007/00"
php collocations-count.php leader06_typeOfRecord_ss 007common00_PhysicalDescription_categoryOfMaterial_ss ldr06-00700 >> ungvary-counts.csv
echo "5/12) LEADER 07 versus 007/00"
php collocations-count.php leader07_bibliographicLevel_ss 007common00_PhysicalDescription_categoryOfMaterial_ss ldr07-00700 >> ungvary-counts.csv
echo "6/12) LEADER 17 versus 007/00"
php collocations-count.php leader17_encodingLevel_ss 007common00_PhysicalDescription_categoryOfMaterial_ss ldr17-00700 >> ungvary-counts.csv
echo "7/12) LEADER 06 versus 007 00 a 01"
php collocations-count.php leader06_typeOfRecord_ss 007map01_PhysicalDescription_specificMaterialDesignation_ss ldr06-007map01material >> ungvary-counts.csv
echo "8/12) LEADER 06 versus 007 00 t 01"
php collocations-count.php leader06_typeOfRecord_ss 007text01_PhysicalDescription_specificMaterialDesignation_ss ldr06-007text01material >> ungvary-counts.csv
echo "9/12) 007 a 01 versus 008 18–21"
php collocations-count.php 007map01_PhysicalDescription_specificMaterialDesignation_ss 008book18_GeneralInformation_illustrations_ss 007map01material-008book18ill >> ungvary-counts.csv
echo "10/12) 007 00 t 01 versus 008 18-21"
php collocations-count.php 007text01_PhysicalDescription_specificMaterialDesignation_ss 008book18_GeneralInformation_illustrations_ss 007text01material-008book18ill >> ungvary-counts.csv
echo "11/12) 007 00 t 01 versus 008 24-27"
php collocations-count.php 007text01_PhysicalDescription_specificMaterialDesignation_ss 008book24_GeneralInformation_natureOfContents_ss 007text01material-008book24nature >> ungvary-counts.csv
echo "12/12) 007 00 t 01 versus 008 33"
php collocations-count.php 007text01_PhysicalDescription_specificMaterialDesignation_ss 008book33_GeneralInformation_literaryForm_ss 007text01material-008book33lit >> ungvary-counts.csv
echo "13/13) térkép, 007/01=a 01 versus térkép, fizikai hordozó, 007/04"
php collocations-count.php 007map01_PhysicalDescription_specificMaterialDesignation_ss 007map04_PhysicalDescription_physicalMedium_ss 007map01material-007map04medium >> ungvary-counts.csv

echo DONE
