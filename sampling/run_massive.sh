#!/bin/bash
#SBATCH --job-name=rm_large_500k
#SBATCH --account=project_462000353
#SBATCH --partition=small
#SBATCH --time=6:20:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
##SBATCH --hint=nomultithread
#SBATCH --cpus-per-task=128
#SBATCH -o logs/%x-%j.out

module load LUMI
module load parallel

REGISTER=$1
lang="eng_Latn"
word_limit=500000

echo "Removing too large files with word limit ${word_limit}"

data="/scratch/project_462000353/amanda/register-training/register-model-training/sampling/results/${lang}/${REGISTER}"
#output="/scratch/project_462000353/amanda/register-training/register-model-training/sampling/results_corrected/${lang}/${REGISTER}"
output="/scratch/project_462000353/HPLT-REGISTERS/samples-150B-by-register-xlmrl/original_corrected"

mkdir -p $output

echo "Start: $(date)"

#for filename in ${data}/*[0-9].jsonl; do  # ending in number so that no combination files are taken into if they exist
cat ${data}/*[0-9].jsonl | parallel --pipe -j128 python3 remove_massive_jsonl.py $word_limit > ${output}/${lang}_${REGISTER}_length_filtered.jsonl
#done


echo "end: $(date)"

cp logs/$SLURM_JOBNAME-$SLURM_JOBID.out logs/$SLURM_JOBNAME-${REGISTER}.out
#mv logs/$SLURM_JOBID.err logs/correct-${REGISTER}.err
