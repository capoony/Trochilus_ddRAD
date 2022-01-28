import sys
from collections import defaultdict as d
from optparse import OptionParser, OptionGroup
from rpy2.robjects import r
import rpy2.robjects as robjects

# Author: Martin Kapun

#########################################################   HELP   #########################################################################
usage = "python %prog --input file --output file "
parser = OptionParser(usage=usage)
group = OptionGroup(parser, "< put description here >")

#########################################################   CODE   #########################################################################

parser.add_option("--input", dest="IN", help="Input file")
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


D = d(lambda: d(lambda: d(int)))
Init = 0

CovFullDict = d(lambda: d(lambda: d(list)))
X = 1
for l in load_data(options.IN):
    if X % 10000000 == 0:
        print(X)
        # break
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
        GT = []

    if a[0] != chr:

        # calculate what proportion of the sample are covered for a given Locus
        CV = len(CovDict.keys()) / len(header)
        # print(CV)
        # store the number of SNPs per locus
        D[round(CV, 2)][chr]["SNPs"] = SNPs
        D[round(CV, 2)][chr]["max"] = MAX
        if len(GT) == 0:
            D[round(CV, 2)][chr]["GT"] = "na"
        else:
            D[round(CV, 2)][chr]["GT"] = sum([GT.count("0|1"), GT.count("1|0")]) / len(
                GT
            )

        # reset counters
        chr = a[0]
        SNPs = 0
        CovDict = d(list)
        GT = []
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
            GT.append(DS["GT"])
        SNPs += 1
    else:
        for i in range(len(pops)):
            if pops[i] == ".":
                continue
            CovDict[header[i]].append(int(pops[i]))

D[round(CV, 2)][chr]["SNPs"] = SNPs
D[round(CV, 2)][chr]["max"] = MAX
if len(GT) == 0:
    D[round(CV, 2)][chr]["GT"] = "na"
else:
    D[round(CV, 2)][chr]["GT"] = sum(
        [GT.count("0|1"), GT.count("1|0")]) / len(GT)

for R, V in sorted(D.items(), reverse=True):
    L = len(V.keys())
    SNPdens = []
    SNPCount = []
    GTcount = []
    Poly = 0
    for k, v in sorted(V.items()):
        # print(v)
        if v["SNPs"] != 0:
            Poly += 1
            SNPCount.append(v["SNPs"])
            GTcount.append(v["GT"])
    r.assign("SNPs", robjects.vectors.FloatVector(SNPCount))
    r.assign("GT", robjects.vectors.FloatVector(GTcount))
    r('library(ggplot2)')
    r('library(gridExtra)')
    r('SNPs.p<-ggplot()+aes(SNPs)+geom_histogram(bins=25)+theme_bw()+ggtitle("SNPcount/Locus")')
    r('GT.p<-ggplot()+aes(GT)+geom_histogram(bins=50)+theme_bw()+ggtitle("Average Heterozygosity")')
    r('PLOT<-grid.arrange(SNPs.p,GT.p,ncol=2)')
    r('ggsave("' + options.OUT + "_" + str(R) + '.png",PLOT,width=12,height=6)')
