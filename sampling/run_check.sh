#!/bin/bash
#SBATCH --job-name=correct
#SBATCH --account=project_462000449  # for resource and queue efficiency
#SBATCH --partition=small
#SBATCH --time=6:20:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
##SBATCH --hint=nomultithread
#SBATCH --cpus-per-task=64
#SBATCH -o logs/%j.out

module load LUMI
module load parallel

REGISTER=$1
lang="eng_Latn"

echo "CORRECTING REGISTER ${REGISTER}"

data="/scratch/project_462000353/amanda/register-training/register-model-training/sampling/results/${lang}/${REGISTER}"
#output="/scratch/project_462000353/amanda/register-training/register-model-training/sampling/results_corrected/${lang}/${REGISTER}"
output="/scratch/project_462000353/HPLT-REGISTERS/samples-150B-by-register-xlmrl/original_corrected"

mkdir -p $output

echo "Start: $(date)"

#for filename in ${data}/*[0-9].jsonl; do  # ending in number so that no combination files are taken into if they exist
cat ${data}/*[0-9].jsonl | parallel --pipe -j64 python3 check_valid_jsonl.py $REGISTER > ${output}/${lang}_${REGISTER}.jsonl
#done


echo "end: $(date)"

cp logs/$SLURM_JOBID.out logs/real-correct2-${REGISTER}.out
#mv logs/$SLURM_JOBID.err logs/correct-${REGISTER}.err
