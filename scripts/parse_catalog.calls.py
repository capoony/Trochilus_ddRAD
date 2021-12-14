import sys
from collections import defaultdict as d
from optparse import OptionParser, OptionGroup

# Author: Martin Kapun

#########################################################   HELP   #########################################################################
usage = "python %prog --input file --output file "
parser = OptionParser(usage=usage)
group = OptionGroup(parser, "< put description here >")

#########################################################   CODE   #########################################################################

parser.add_option("--input", dest="IN", help="Input file")
parser.add_option("--name", dest="name", help="Name")

(options, args) = parser.parse_args()
parser.add_option_group(group)


def load_data(x):
    """ import data either from a gzipped or or uncrompessed file or from STDIN"""
    import gzip

    if x == "-":
        y = sys.stdin
    elif x.endswith(".calls"):
        y = gzip.open(x, "rt", encoding="latin-1")
    else:
        y = open(x, "r", encoding="latin-1")
    return y


D = d(lambda: d(int))
Init = 0

for l in load_data(options.IN):
    if l.startswith("#"):
        continue
    a = l.rstrip().split()

    if Init == 0:

        chr = a[0]
        MAX = a[1]
        SNPs = 0
        Init = 1
    # print(a, MAX)
    if a[0] != chr:
        D[chr]["max"] = MAX
        D[chr]["SNPs"] = SNPs
        # print(l, MAX, a[1], SNPs, a[0], chr)
        chr = a[0]
        SNPs = 0
    if a[4] != ".":
        SNPs += 1
    MAX = a[1]
D[chr]["max"] = MAX
D[chr]["SNPs"] = SNPs


def meanstdv(x):
    """ calculate mean, stdev and standard error : x must be a list of numbers"""
    from math import sqrt

    n, mean, std, se = len(x), 0, 0, 0
    if len(x) == 0:
        return "na", "na", "na"
    for a in x:
        mean = mean + a
    mean = mean / float(n)
    if len(x) > 1:
        for a in x:
            std = std + (a - mean) ** 2
        std = sqrt(std / float(n - 1))
        se = std / sqrt(n)
    else:
        std = 0
        se = 0
    return mean, std, se


L = len(D.keys())
SNPdens = []
ContigLen = []
SNPCount = []
Poly = 0
for k, v in sorted(D.items()):

    ContigLen.append(int(v["max"]))
    if v["SNPs"] != 0:
        Poly += 1
        SNPdens.append(v["SNPs"] / float(v["max"]))
        SNPCount.append(v["SNPs"])
    # print(options.name, k, v["max"], v["SNPs"], v["SNPs"] / float(v["max"]), sep="\t")

print(
    options.name,
    L,
    Poly,
    round(Poly / L, 2),
    "\t".join([str(round(x, 1)) for x in meanstdv(ContigLen)[:2]]),
    "\t".join([str(round(x, 1)) for x in meanstdv(SNPCount)[:2]]),
    "\t".join([str(round(x, 5)) for x in meanstdv(SNPdens)[:2]]),
    sep="\t",
)
