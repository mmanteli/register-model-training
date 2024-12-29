import json
import sys
import random
import io
register = str(sys.argv[1])

limits_en = {
	"dtp":1,
	"HI": 1,
	"ID": 0.5,   # were donwsampling now because it is efficient here
	"IN": 0.8,
	"IP": 1,
	"MT": 0.5,
	"NA": 1,
	"ne": 1,
	"OP": 1,
	"SP": 1,
	"LY": 1,
	"no-label": 0.8,
	"HI-IN": 1,
}

limit = limits_en[register]
sys.stdin = io.TextIOWrapper(sys.stdin.buffer, encoding='utf8', errors='replace')  # 'replace' handles non-ASCII characters


# PIPED INPUT
for line in sys.stdin:
    if random.random() < limit:
        try:
            j = json.loads(line)
            print(json.dumps(j))  #tested to be faster than .get etc
        except:
            continue
