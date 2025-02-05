#!/bin/bash
#SBATCH --job-name=TEST-IN-register-llama-1.8B
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --cpus-per-task=7
#SBATCH --mem=480G
#SBATCH --exclusive
#SBATCH --partition=dev-g
#SBATCH --time=00:29:00
#SBATCH --gpus-per-node=8
#SBATCH --account=project_462000353
#SBATCH --output=logs/%x-%j.out
#SBATCH --error=logs/%x-%j.err

# symlink logs/latest.out and logs/latest.err
ln -f -s $SLURM_JOB_NAME-$SLURM_JOB_ID.out logs/latest.out
ln -f -s $SLURM_JOB_NAME-$SLURM_JOB_ID.err logs/latest.err

REGISTER=$1
if [ $# -eq 0 ]
  then
    echo "Input register as parameter."
    exit 2
fi
NEOX_DIR=/scratch/project_462000353/amanda/register-training/gpt-neox

module purge
export EBU_USER_PREFIX=/projappl/project_462000353/Easybuild
module load LUMI partition/G
module load PyTorch/2.3.0pytorch-2.3.0-rocm-6.2.0-python-3.10

export TRANSFORMERS_CACHE=/scratch/project_462000353/transformers_cache
# $HF_HOME #/scratch/project_462000353/amanda/cache #Change this

#LOGGING VERBOSITY
export SINGULARITYENV_TRANSFORMERS_NO_ADVISORY_WARNINGS=1
export SINGULARITYENV_TRANSFORMERS_VERBOSITY=error

#Compilers for data builders
export SINGULARITYENV_CC=gcc-12
export SINGULARITYENV_CXX=g++-12

#Reduce verbosity in logs
export SINGULARITYENV_PYTHONWARNINGS=ignore
export SINGULARITYENV_LANGUAGE="en_US.UTF-8" #Perl complains if these are not set
export SINGULARITYENV_LC_ALL="en_US.UTF-8"

export MASTER_ADDR=$(scontrol show hostnames "$SLURM_JOB_NODELIST" | head -n 1)
export MASTER_PORT=9999

CONFIG="/scratch/project_462000353/amanda/register-training/register-model-training/configs/${REGISTER}_1_82B_${SLURM_NNODES}N.yml"
if [ ! -e $CONFIG ]; then
    echo "Config does not exist, creating it from template."
    TEMPLATE="/scratch/project_462000353/amanda/register-training/register-model-training/configs/template_1_82B_8N.yml"
    sed "s/{{REGISTER}}/${REGISTER}/g" $TEMPLATE > $CONFIG
fi

echo "CONF" $CONFIG
cat $CONFIG

# create hostfile
HOSTFILE="hostfiles/$SLURM_JOB_ID.txt"
mkdir -p $(dirname "$HOSTFILE")
scontrol show hostnames "$SLURM_JOB_NODELIST" | while read n; do
    echo "$n slots=8" >> "$HOSTFILE"
done

#CPU Bindings
c=fe
MYMASKS="0x${c}000000000000,0x${c}00000000000000,0x${c}0000,0x${c}000000,0x${c},0x${c}00,0x${c}00000000,0x${c}0000000000"

echo "START: $(date)"
echo "NNODES: $((SLURM_NNODES))"
echo "CPUS-PER-TASK: $((SLURM_CPUS_PER_TASK))"


srun --cpu-bind=mask_cpu:$MYMASKS --label singularity exec $SIFPYTORCH \
    conda-python-distributed ${NEOX_DIR}/run.py \
    ${NEOX_DIR}/train.py $CONFIG \
    --hostfile $HOSTFILE

rm hostfiles/*
cp logs/$SLURM_JOB_NAME-$SLURM_JOB_ID.out logs/$SLURM_JOB_NAME-$REGISTER-$SLURM_JOB_ID.out
cp logs/$SLURM_JOB_NAME-$SLURM_JOB_ID.err logs/$SLURM_JOB_NAME-$REGISTER-$SLURM_JOB_ID.err
echo "END: $(date)"
