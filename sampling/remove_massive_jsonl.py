import json
import sys
import random
import io
import re
sys.stdin = io.TextIOWrapper(sys.stdin.buffer, encoding='utf8', errors='replace')  # 'replace' handles non-ASCII characters
limit = sys.argv[1]
# PIPED INPUT
for line in sys.stdin:
    try:
        j = json.loads(line)
        num_words = len(re.split(r'[\s]+',j["text"]))
        if num_words < limit:
            print(json.dumps(j))
    except:
        continue
