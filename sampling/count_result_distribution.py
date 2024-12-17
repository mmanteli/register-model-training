import json
from collections import defaultdict

def sum_jsonl_keys(file_path):
    """
    Reads a JSON Lines file and sums the values for each key across all rows.

    :param file_path: Path to the JSON Lines file
    :return: Dictionary with the summed values for each key
    """
    key_sums = defaultdict(int)  # Default value for each key is 0

    try:
        with open(file_path, 'r') as f:
            for line in f:
                if line.strip():  # Ignore empty lines
                    # Replace single quotes with double quotes for valid JSON
                    line = line.replace("'", '"')
                    data = json.loads(line)
                    for key, value in data.items():
                        key_sums[key] += value

        return dict(key_sums)

    except FileNotFoundError:
        print(f"Error: File '{file_path}' not found.")
        return {}
    except json.JSONDecodeError:
        print("Error: File contains invalid JSON.")
        return {}
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
        return {}

if __name__ == "__main__":
    # Specify the path to your JSONL file
    jsonl_file = "/scratch/project_462000353/amanda/register-training/register-model-training/sampling/logs/register_sample-8777578.out"

    # Compute the sums
    result = sum_jsonl_keys(jsonl_file)

    if result:
        print("Summed values by key:")
        for key, total in result.items():
            print(f"{key}: {total}")