import json
import sys
import random
import io
import re
#import math
sys.stdin = io.TextIOWrapper(sys.stdin.buffer, encoding='utf8', errors='replace')  # 'replace' handles non-ASCII characters


"""
def round_down(x, k=3):
    n = 10**k
    return x // n * n

def bins(num_words, bins):
    bin_to_put = int(math.log10(num_words+1))

    if len(bins) < bin_to_put + 1:
        for i in range(len(bins), bin_to_put+1):
            bins.append(0)
    bins[bin_to_put] += 1
"""


# PIPED INPUT
for line in sys.stdin:
    try:
        j = json.loads(line)
        id_ = j["id"] if "id" in j.keys() else j["url"]
        num_words = len(re.split(r'[\s]+',j["text"]))
        print(str(id_), "\t", str(num_words))
    except:
        continue