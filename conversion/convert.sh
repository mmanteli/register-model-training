#!/bin/bash
#SBATCH --job-name=convert2HF_cpu
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=7
#SBATCH --mem=20G
#SBATCH --partition=small
#SBATCH --time=00:06:00
#SBATCH --account=project_462000353
#SBATCH --output=logs/%x/%j.out
#SBATCH --error=logs/%x/%j.err
# symlink logs/latest.out and logs/latest.err
#ln -f -s $SLURM_JOB_NAME-$SLURM_JOB_ID.out logs/latest.out
#ln -f -s $SLURM_JOB_NAME-$SLURM_JOB_ID.err logs/latest.err


# check input arguments to be exactly 3
if [ "$#" -ne 3 ]; then
    echo "Usage: register input_folder output_folder"
    exit 1
fi

REGISTER=$1
config_file="/scratch/project_462000353/amanda/register-training/register-model-training/configs/${REGISTER}_1_82B_8N.yml"

if [ ! -e $config_file]; then
    echo "Config does not exist: " $config_file
    exit 1
fi

input_folder=$2   # for example: /scratch/project_462000353/amanda/register-training/checkpoints/8N/ID/global_step1000
output_folder=$3  # same but with different checkpoint folder (e.g. "conterted_checkpoints")


module purge
export EBU_USER_PREFIX=/projappl/project_462000353/Easybuild
module load LUMI/23.09
module load PyTorch/2.2.2-rocm-5.6.1-python-3.10-singularity-20240617

export HF_HOME=/scratch/project_462000353/cache
export TRANSFORMERS_CACHE=/scratch/project_462000353/cache

export SINGULARITYENV_TORCH_DISTRIBUTED_DEBUG=DETAIL
export SINGULARITYENV_TRANSFORMERS_NO_ADVISORY_WARNINGS=1
export SINGULARITYENV_TRANSFORMERS_VERBOSITY=error

#Compilers for data builders
export SINGULARITYENV_CC=gcc-10
export SINGULARITYENV_CXX=g++-10

#Reduce verbosity in logs
export SINGULARITYENV_PYTHONWARNINGS=ignore
export SINGULARITYENV_LANGUAGE="en_US.UTF-8" #Perl complains if these are not set
export SINGULARITYENV_LC_ALL="en_US.UTF-8"

echo "START: $(date)"
echo "NNODES: $((SLURM_NNODES))"
echo "CPUS-PER-TASK: $((SLURM_CPUS_PER_TASK))"

echo "$config_file"
echo "$input_folder"
echo "$output_folder"

NEOX_DIR=/scratch/project_462000353/amanda/register-training/gpt-neox

srun --label singularity exec $SIFPYTORCH \
    conda-python-distributed ${NEOX_DIR}/tools/ckpts/convert_neox_to_hf.py \
            --config_file "$config_file"  \
            --input_dir "$input_folder" \
            --output_dir "$output_folder" \
            --architecture "llama" \
            --no_save_tokenizer 
