#!/usr/bin/env bash

CAT=$1
if [[ "$CAT" == "" ]]; then
  echo "Give a catalogue name"
fi

OUTPUT=ungvary
if [[ ! -d $OUTPUT ]]; then
  mkdir $OUTPUT
fi

echo "1/13) LEADER 06 versus LEADER 07"
php collocations.php leader06_typeOfRecord_ss leader07_bibliographicLevel_ss > $OUTPUT/$CAT-ldr06-ldr07.csv
echo "2/13) LEADER 06 versus LEADER 17"
php collocations.php leader06_typeOfRecord_ss leader17_encodingLevel_ss > $OUTPUT/$CAT-ldr06-ldr17.csv
echo "3/13) LEADER 07 versus LEADER 17"
php collocations.php leader07_bibliographicLevel_ss leader17_encodingLevel_ss > $OUTPUT/$CAT-ldr07-ldr17.csv

echo "4/13) LEADER 06 versus 007/00"
php collocations.php leader06_typeOfRecord_ss 007common00_PhysicalDescription_categoryOfMaterial_ss > $OUTPUT/$CAT-ldr06-00700.csv
echo "5/13) LEADER 07 versus 007/00"
php collocations.php leader07_bibliographicLevel_ss 007common00_PhysicalDescription_categoryOfMaterial_ss > $OUTPUT/$CAT-ldr07-00700.csv
echo "6/13) LEADER 17 versus 007/00"
php collocations.php leader17_encodingLevel_ss 007common00_PhysicalDescription_categoryOfMaterial_ss > $OUTPUT/$CAT-ldr17-00700.csv

echo "7/13) LEADER 06 versus 007 00 a 01"
php collocations.php leader06_typeOfRecord_ss 007map01_PhysicalDescription_specificMaterialDesignation_ss > $OUTPUT/$CAT-ldr06-007map01material.csv
echo "8/13) LEADER 06 versus 007 00 t 01"
php collocations.php leader06_typeOfRecord_ss 007text01_PhysicalDescription_specificMaterialDesignation_ss > $OUTPUT/$CAT-ldr06-007text01material.csv
echo "9/13) 007 a 01 versus 008 18–21"
php collocations.php 007map01_PhysicalDescription_specificMaterialDesignation_ss 008book18_GeneralInformation_illustrations_ss > $OUTPUT/$CAT-007map01material-008book18ill.csv

echo "10/13) 007 00 t 01 versus 008 18-21"
php collocations.php 007text01_PhysicalDescription_specificMaterialDesignation_ss 008book18_GeneralInformation_illustrations_ss > $OUTPUT/$CAT-007text01material-008book18ill.csv
echo "11/13) 007 00 t 01 versus 008 24-27"
php collocations.php 007text01_PhysicalDescription_specificMaterialDesignation_ss 008book24_GeneralInformation_natureOfContents_ss > $OUTPUT/$CAT-007text01material-008book24nature.csv
echo "12/13) 007 00 t 01 versus 008 33"
php collocations.php 007text01_PhysicalDescription_specificMaterialDesignation_ss 008book33_GeneralInformation_literaryForm_ss > $OUTPUT/$CAT-007text01material-008book33lit.csv

echo "13/13) térkép, 007/01=a 01 versus térkép, fizikai hordozó, 007/04"
php collocations.php 007map01_PhysicalDescription_specificMaterialDesignation_ss 007map04_PhysicalDescription_physicalMedium_ss > $OUTPUT/$CAT-007map01material-007map04medium.csv

echo DONE
