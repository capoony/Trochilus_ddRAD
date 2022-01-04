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
parser.add_option("--output", dest="OUT", help="Outputfile prefix")

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


D = d(lambda: d(lambda: d(int)))
Init = 0

CovFullDict = d(lambda: d(lambda: d(list)))
X = 1
for l in load_data(options.IN):
    # if X % 10000000 == 0:
    #     print(X)
    # skip description header
    if l.startswith("##"):
        continue
    # store name of samples
    if l.startswith("#"):
        a = l.rstrip().split()
        header = a[9:]
        continue
    # split line
    a = l.rstrip().split()

    # initiate counting at first entry
    if Init == 0:
        chr = a[0]
        MAX = a[1]
        SNPs = 0
        Init = 1
        CovDict = d(list)

    if a[0] != chr:

        # calculate what proportion of the sample are covered for a given Locus
        CV = len(CovDict.keys()) / len(header)
        # print(CV)
        # store the number of SNPs per locus
        D[round(CV, 2)][chr]["SNPs"] = SNPs
        D[round(CV, 2)][chr]["max"] = MAX
        if SNPs == 0:
            Poly = 0
        else:
            Poly = 1
        for h in header:
            if h in CovDict:
                CovFullDict[round(CV, 2)][Poly][h].append(
                    meanstdv(CovDict[h])[0])

        # reset counters
        chr = a[0]
        SNPs = 0
        CovDict = d(list)
    X += 1

    MAX = a[1]

    # summarize coverages
    pops = a[9:]

    # count if polymorphic
    if a[4] != ".":
        for i in range(len(pops)):
            if pops[i].split(":")[0] == "./.":
                continue
            DS = dict(zip(a[8].split(":"), pops[i].split(":")))
            CovDict[header[i]].append(int(DS["DP"]))
        SNPs += 1
    else:
        for i in range(len(pops)):
            if pops[i] == ".":
                continue
            CovDict[header[i]].append(int(pops[i]))

D[round(CV, 2)][chr]["SNPs"] = SNPs
D[round(CV, 2)][chr]["max"] = MAX
if SNPs == 0:
    Poly = 0
else:
    Poly = 1
for h in header:
    if h in CovDict:
        CovFullDict[round(CV, 2)][Poly][h].append(meanstdv(CovDict[h])[0])

FullDens = []
FullCount = []
FullLoci = 0
FullPoly = 0
out1 = open(options.OUT + "_stats.txt", "a")
for R, V in sorted(D.items(), reverse=True):
    L = len(V.keys())
    SNPdens = []
    SNPCount = []
    Poly = 0
    for k, v in sorted(V.items()):
        # print(v)
        if v["SNPs"] != 0:
            Poly += 1
            SNPdens.append(v["SNPs"] / float(v["max"]))
            SNPCount.append(v["SNPs"])
        # print(options.name, k, v["max"], v["SNPs"], v["SNPs"] / float(v["max"]), sep="\t")
    FullDens.extend(SNPdens)
    FullCount.extend(SNPCount)
    FullLoci += L
    FullPoly += Poly
    FullPropPoly = round(FullPoly / FullLoci, 2)
    out1.write(
        "\t".join(
            [
                str(x)
                for x in [
                    options.name,
                    R,
                    L,
                    Poly,
                    round(Poly / L, 2),
                    "\t".join([str(round(x, 1))
                              for x in meanstdv(SNPCount)[:2]]),
                    "\t".join([str(round(x, 5))
                              for x in meanstdv(SNPdens)[:2]]),
                    FullLoci,
                    FullPoly,
                    FullPropPoly,
                    "\t".join([str(round(x, 1))
                              for x in meanstdv(FullCount)[:2]]),
                    "\t".join([str(round(x, 5))
                              for x in meanstdv(FullDens)[:2]]),
                ]
            ]
        )
        + "\n"
    )

out2 = open(options.OUT + "_cov.txt", "a")

for Prop, v in sorted(CovFullDict.items()):
    for Poly, v1 in sorted(v.items()):
        for h, c in sorted(v1.items()):
            out2.write(
                "\t".join(
                    [
                        options.name,
                        str(Prop),
                        str(Poly),
                        h,
                        "\t".join([str(round(x, 1)) for x in meanstdv(c)[:2]]),
                    ]
                )
                + "\n"
            )
