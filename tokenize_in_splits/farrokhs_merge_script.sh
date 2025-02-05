#!/bin/bash
#SBATCH -A project_462000615
#SBATCH -p small
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=200G
#SBATCH -t 04:00:00
#SBATCH -N 1
#SBATCH -J MERGE-IN
#SBATCH --output=logs/%x-%j.out
#SBATCH --error=logs/%x-%j.err

#USAGE: sbatch merge_tokenized_data.sh /scratch/path/to/bins_and_idx/ /scratch/path_to_output/merged 
#EXAMPLE: sbatch merge_tokenized_data.sh /scratch/project_462000353/farmeh/merge_with_patched_neox/slurm_merge_scripts/test_data/bin_folder/ /scratch/project_462000353/farmeh/merge_with_patched_neox/slurm_merge_scripts/test_data/merged 

# check input arguments to be exactly 2
#if [ "$#" -ne 2 ]; then
#    echo "Usage: input_folder output_bin_path_without_dot_bin"
#    exit 1
#fi

# Assign the input arguments 
input_folder_path="/scratch/project_462000353/HPLT-REGISTERS/samples-150B-by-register-xlmrl/tokenized/IN-splitted"
                    #"$1" #Path to directory containing all document files to merge
output_bin_path="/scratch/project_462000353/HPLT-REGISTERS/samples-150B-by-register-xlmrl/tokenized/IN/eng_Latn_text_document"
                    #"$2" #Path to binary output file without suffix

# Ensure the path ends with a "/"
input_folder_path="${input_folder_path%/}/"

# Remove trailing slash if present
output_bin_path="${output_bin_path%/}"

#echo ... 
echo "START: $(date '+%A, %B %d, %Y at %I:%M:%S %p')"
echo "INPUT FOLDER                      : $input_folder_path" 
echo "OUTPUT .BIN FILE PATH WITHOUT .BIN: $output_bin_path"

# prepare environment ... 
module purge
export EBU_USER_PREFIX=/projappl/project_462000353/Easybuild
module load LUMI/23.09
module load PyTorch/2.2.2-rocm-5.6.1-python-3.10-singularity-20240617

# <<<CRITICAL>>>: make sure to use updated neox path, the one which is patched by Ville recently 
# for example, now I have it here: /scratch/project_462000353/farmeh/merge_with_patched_neox/gpt-neox/tools/datasets/merge_datasets.py

echo "USING ${SLURM_CPUS_PER_TASK} CPU'S TO TOKENIZE"
srun singularity exec $SIF python /scratch/project_462000353/farmeh/merge_with_patched_neox/gpt-neox/tools/datasets/merge_datasets.py \
            --input=$input_folder_path \
            --output-prefix=$output_bin_path
echo "END: $(date '+%A, %B %d, %Y at %I:%M:%S %p')"
