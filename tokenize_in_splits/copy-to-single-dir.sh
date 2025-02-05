#!/bin/bash


input="/scratch/project_462000353/amanda/register-training/register-model-training/sampling/results/tmp/IN/tokenized"
output="/scratch/project_462000353/HPLT-REGISTERS/samples-150B-by-register-xlmrl/tokenized/IN-splitted"


for dir in $input/*; do
    if [ -d "$dir" ]; then
        new_name=$(basename "$dir") # | sed 's/split_//')   # flatten
        echo "in directory ${new_name}"

        # check correct number of files...
        bin_files=$(find "$dir" -maxdepth 1 -type f -name "*.bin" | wc -l)
        idx_files=$(find "$dir" -maxdepth 1 -type f -name "*.idx" | wc -l)
        
        # Check if there is exactly one .bin and one .idx file
        if (( bin_files == 1 )) && ((idx_files == 1)); then
            echo "bin and idx found"
            destination="${output}/${new_name}_eng_Latn_text_document"
            #if [ -f ${dir}/eng_Latn_text_document.bin ]; then
            #    echo "bin found copying to ${destination}.bin"
            #fi
            #if [ -f ${dir}/eng_Latn_text_document.idx ]; then
            #    echo "idx found copying to ${destination}.idx"
            #fi
            cp ${dir}/eng_Latn_text_document.idx $destination.idx
            cp ${dir}/eng_Latn_text_document.bin $destination.bin
        fi

    fi
done