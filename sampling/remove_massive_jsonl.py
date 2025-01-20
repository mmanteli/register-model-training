import json
import sys
import random
import io
import re
sys.stdin = io.TextIOWrapper(sys.stdin.buffer, encoding='utf8', errors='replace')  # 'replace' handles non-ASCII characters

# PIPED INPUT
for line in sys.stdin:
    try:
        j = json.loads(line)
        num_words = len(re.split(r'[\s]+',j["text"]))
        if num_words < 600000:
            print(json.dumps(j))
    except:
        continue
