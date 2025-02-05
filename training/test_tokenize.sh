#!/bin/bash
#SBATCH -A project_462000615
#SBATCH -p debug
#SBATCH --ntasks-per-node=1
##SBATCH --gpus-per-node=1
#SBATCH --cpus-per-task=128
#SBATCH --mem=0
#SBATCH -t 00:10:00
#SBATCH -N 1
#SBATCH -J test-tokenisation
#SBATCH -o logs/%x.out

address="/scratch/project_462000353/amanda/register-training/gpt-neox"
register="IN"
lang="eng_Latn"
module purge
module load pytorch

echo "USING ${SLURM_CPUS_PER_TASK} CPU'S TO TOKENIZE ${lang} ${register}"
input="/scratch/project_462000353/HPLT-REGISTERS/samples-150B-by-register-xlmrl/original_corrected/${lang}_${register}_less_than_600k.jsonl" #eng_Latn_no-label_less_than_600k.jsonl
output="/scratch/project_462000353/HPLT-REGISTERS/samples-150B-by-register-xlmrl/tokenized/${register}_new"
#input="/scratch/project_462000353/HPLT-REGISTERS/samples-150B-by-register-xlmrl/original_corrected/${lang}_${register}_with_th_1.jsonl"
#output="/scratch/project_462000353/HPLT-REGISTERS/samples-150B-by-register-xlmrl/tokenized/${register}"


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
            --log-interval=1000000 \
            --output-prefix="${output}/${lang}"
sacct --format="JobId,Elapsed" -j $SLURM_JOB_ID
