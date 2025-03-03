#!/bin/bash
#SBATCH -A project_462000615
#SBATCH -p small
#SBATCH --ntasks-per-node=1
##SBATCH --gpus-per-node=1
#SBATCH --cpus-per-task=128
#SBATCH --mem=480G
#SBATCH -t 4:30:00
#SBATCH -N 1
#SBATCH -J tokenize-merged
#SBATCH -o logs_in_parts/%x-%j.out

address="/scratch/project_462000353/amanda/register-training/gpt-neox"
register="IN"
lang="eng_Latn"
module purge
module load pytorch



echo "USING ${SLURM_CPUS_PER_TASK} CPU'S TO TOKENIZE ${lang} ${register}"



# make temp file
temp_location="/scratch/project_462000353/amanda/register-training/register-model-training/sampling/results/tmp/${register}_full"
mkdir -p $temp_location
temp_file="${temp_location}/${register}_full_temp.jsonl"

cat $(ls -d /scratch/project_462000353/HPLT-REGISTERS/samples-150B-by-register-xlmrl/original_corrected/IN-splitted/* | egrep -ve 'eng_Latn_IN_[0-9]*9_04.jsonl|eng_Latn_IN_[0-9]*4_05.jsonl') > $temp_file


input=$temp_file
output="/flash/project_462000353/registers/${register}"



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