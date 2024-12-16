#!/bin/bash

# Define input and output directories for all registers
INPUT_DIR="/scratch/project_462000353/amanda/register-training/checkpoints/8N/{{REGISTER}}"


for register in dtp HI ID IN IP NA ne OP; do
    replacement="$register" # as a string so that sed works (??)
    ckps=$(echo "$INPUT_DIR" | sed "s|{{REGISTER}}|$replacement|")
    #converted=$(echo "$ckps" | sed 's|checkpoints|checkpoints_converted|') 
    for input in ${ckps}/"global_step"*; do
        #echo $register $input
        output=$(echo "$input" | sed 's|checkpoints|checkpoints_converted|') 
        if [[ -d "$output" ]]; then
            # Count files ending with .safetensors
            FILE_COUNT=$(find "$output" -maxdepth 1 -type f -name "*.safetensors" | wc -l)
            if (( FILE_COUNT >= 2 )); then
                echo "Directory exists and contains at least two .safetensors files, no recalculation."
                continue 1
            fi
        fi
        sbatch convert.sh $register $input $output
        done
done
