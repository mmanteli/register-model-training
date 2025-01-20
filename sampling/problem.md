# Background

At the start, when using gnu parallel, sometimes some jsonls where badly formatted. This meant that running separate checking (which could be used for combining the files as well!) had to be run.

This corrected all issues except for "IN" and "no-label" registers. The hypothesis is that they contain some monster files that tokenisation runs out of memory.

# How to correct this


The first idea is of cource to remove these large files. Do they exist? Maybe calculating the length distribution is helpful. Should I also at the same time remove some limit? Like a guess so that if I see it is at the 95% percentile I can just move on with my life.

## See if the problem is actually caused by too long files

Yes, it was. Filtering by 5000 words (arbitrary) fixed tokenisation

## How about now?

I'm actually going to calculate the distribution in bins of 1000 words.


