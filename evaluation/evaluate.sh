#!/bin/bash
#SBATCH --job-name=evaluate
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=7
#SBATCH --mem=30G
#SBATCH --partition=small-g
#SBATCH --time=12:12:00
#SBATCH --gres=gpu:mi250:1
#SBATCH --account=project_462000353
#SBATCH --output=logs/%x-%j.out
#SBATCH --error=logs/%x-%j.err


module purge
module use /appl/local/csc/modulefiles
module load pytorch
export PYTHONPATH=/scratch/project_462000353/amanda/register-training/pythonuserbase/lib/python3.10/site-packages:$PYTHONPATH


evaluation=$1
REGISTER=$2
STEP=$3
#TASK="arc:challenge"
#num_fewshot=5
model_to_evaluate="/scratch/project_462000353/amanda/register-training/checkpoints_converted/8N/${REGISTER}/global_step${STEP}"


export TRANSFORMERS_CACHE="/scratch/project_462000353/cache"
export HF_HOME="/scratch/project_462000353/cache"

echo "START: $(date)"

case $evaluation in
    "test")
        evaluation="arc_easy_0"
        srun python /scratch/project_462000353/amanda/register-training/pythonuserbase/bin/lighteval accelerate \
            --model_args "pretrained=${model_to_evaluate},tokenizer=gpt2" \
            --tasks "lighteval|arc:easy|0|0" \
            --output_dir eval_results/${evaluation}/ \
            --override_batch_size 16
    ;;
    "fineweb")
        srun python /scratch/project_462000353/amanda/register-training/pythonuserbase/bin/lighteval accelerate \
            --model_args "pretrained=${model_to_evaluate},tokenizer=gpt2" \
            --custom_tasks "/scratch/project_462000353/amanda/register-training/Lighteval-on-LUMI/evals/tasks/lighteval_tasks.py" \
            --max_samples 1000 \
            --tasks "/scratch/project_462000353/amanda/register-training/Lighteval-on-LUMI/evals/tasks/fineweb.txt" \
            --output_dir eval_results/${evaluation}/ \
            --override_batch_size 16
    ;;
    "leaderboard")
        srun python /scratch/project_462000353/amanda/register-training/pythonuserbase/bin/lighteval accelerate \
            --model_args "pretrained=${model_to_evaluate},tokenizer=gpt2" \
            --tasks "/scratch/project_462000353/amanda/register-training/Lighteval-on-LUMI/examples/tasks/open_llm_leaderboard_tasks.txt" \
            --output_dir eval_results/${evaluation}/ \
            --override_batch_size 16
    ;;
    *)
        echo "invalid evaluation given"
    ;;
esac

echo "END: $(date)"

default_location=$(echo $model_to_evaluate | tr "/" "_" )   # this is what lighteval gives
new_location=$(echo $default_location | rev | cut -f 1-3 -d"_" | rev)  # this results in "IP_global_stepXXXX
new_save_path=eval_results/${evaluation}/${REGISTER}/${new_location}/
mkdir -p $new_save_path
mv eval_results/${evaluation}/results/$default_location/* $new_save_path
#rm -r eval_results/${evaluation}/results/$default_location   
