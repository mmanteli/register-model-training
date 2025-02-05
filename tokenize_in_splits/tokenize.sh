#!/bin/bash
#SBATCH -A project_462000615
#SBATCH -p small
#SBATCH --ntasks-per-node=1
##SBATCH --gpus-per-node=1
#SBATCH --cpus-per-task=128
#SBATCH --mem=400G
#SBATCH -t 1:30:00
#SBATCH -N 1
#SBATCH -J tokenize-in-parts
#SBATCH -o logs_in_parts/%x-%j.out

address="/scratch/project_462000353/amanda/register-training/gpt-neox"
register="no-label"
split=$1
lang="eng_Latn"
module purge
module load pytorch
#hplt_index="$2"  # further splitting
str_hplt_index="${hplt_index/\*/X}"   # asterisk to X for filenames


echo "SPLIT ${split}: USING ${SLURM_CPUS_PER_TASK} CPU'S TO TOKENIZE ${lang} ${register}"



# make temp file
temp_location="/scratch/project_462000353/amanda/register-training/register-model-training/sampling/results/tmp/${register}"
mkdir -p $temp_location
temp_file="${temp_location}/${register}_split_0${split}_${str_hplt_index}.jsonl"
cat /scratch/project_462000353/amanda/register-training/register-model-training/sampling/results/eng_Latn/${register}/eng_Latn_${register}_*_0${split}.jsonl > $temp_file

#input="/scratch/project_462000353/HPLT-REGISTERS/samples-150B-by-register-xlmrl/original_corrected/" #eng_Latn_no-label_less_than_600k.jsonl
#output="/scratch/project_462000353/HPLT-REGISTERS/samples-150B-by-register-xlmrl/tokenized/${register}_500k_no_problem"
#input="/scratch/project_462000353/HPLT-REGISTERS/samples-150B-by-register-xlmrl/original_corrected/${lang}_${register}_with_th_1.jsonl"
#output="/scratch/project_462000353/HPLT-REGISTERS/samples-150B-by-register-xlmrl/tokenized/${register}"
input=$temp_file
output="${temp_location}/tokenized/${register}_split_0${split}_hplt_indices_${str_hplt_index}_tokenized_to_be_merged"

if [ ! -e $input ]; then
    echo "Input file does not exist:"
    echo $input
    exit 1
fi
mkdir -p $output


module purge
export EBU_USER_PREFIX=/projappl/project_462000353/Easybuild
module load LUMI/23.09
module load PyTorch/2.2.2-rocm-5.6.1-python-3.10-singularity-20240617

srun singularity exec $SIF python ${address}/tools/datasets/preprocess_data.py \
            --input=$input \
            --tokenizer-type=GPT2BPETokenizer \
            --vocab-file=/scratch/project_462000353/tokenizers/gpt2/vocab.json  \
            --merge-file=/scratch/project_462000353/tokenizers/gpt2/merges.txt \
            --append-eod \
            --workers=$SLURM_CPUS_PER_TASK \
            --log-interval=10000 \
            --output-prefix="${output}/${lang}"

            
sacct --format="JobId,Elapsed" -j $SLURM_JOB_ID
cp logs_in_parts/${SLURM_JOB_NAME}-${SLURM_JOB_ID}.out logs_in_parts/done/${register}_split_0${split}_hplt_index_${str_hplt_index}.out