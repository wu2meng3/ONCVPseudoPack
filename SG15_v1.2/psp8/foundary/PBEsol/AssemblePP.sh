#!/bin/bash
# This script extract the input for ONCVPSP from SG15 PP library (v1.2)
# http://www.quantum-simulation.org/potentials/sg15_oncv/
# and use ONCVPSP v3.3.1 + libxc v3.0.1 to produce ONCVPSP PBEsol pseudopotentials (SR+FR)
# in the format of psp8 for Abinit
# Pseudopotentials are stored in ${OUTPUT_DIR}

INPUT_DIR="../../../INPUT"
OUTPUT_DIR="../../PBEsol"
functional="PBEsol"
surfix="SG15v1.2"
echo "Generating PP with ${functional} functional..."
mkdir -p ${OUTPUT_DIR}
echo "Store PP files in ${OUTPUT_DIR}"
for file in ${INPUT_DIR}/*1.2.upf
do
    filename=$(basename "$file")
    prefix=$(echo ${filename} | awk -F"_O" '{print $1}')
    # echo $file $filename $extension $prefix
    echo "================================================"
    echo $prefix
    line_start=$(grep -a --text -n '# ATOM AND REFERENCE CONFIGURATION' $file | awk -F ":" '{print $1}')
    line_end=$(grep -a --text -n '# nvcnf' $file | awk -F ":" '{print $1+1}')
    # echo $line_start $line_end
    sed -n "$line_start, $line_end p" $file | sed 's/4      upf/-116133      psp8/g' > "./${prefix}.dat"
    ./run.sh ${prefix} -np
    ./extract.sh "${prefix}"
    ./run_r.sh ${prefix} -np
    ./extract.sh "${prefix}_r"

    mv ${prefix}.oncvpsp.psp8 ${OUTPUT_DIR}/"${prefix}_${functional}_SR.${surfix}.psp8"
    mv ${prefix}_r.oncvpsp.psp8 ${OUTPUT_DIR}/"${prefix}_${functional}_FR.${surfix}.psp8"

    rm -rf ${prefix}*.out
    rm -rf ${prefix}*.dat
    echo "================================================"    
done
echo "Done"
