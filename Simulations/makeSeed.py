import random
import os
def makeCodon():
    codon = ""
    AA = "ATCG"
    # print(len(AA),print(AA[0],AA[19]))
    # print( random.randint(0,len(AA)))
    codon += AA[random.randint(0,len(AA)-1)]
    codon += AA[random.randint(0,len(AA)-1)]
    codon += AA[random.randint(0,len(AA)-1)]
    return codon
# print(makeCodon())
def makeSeed(numAA):
    seed ="ATG"
    for i in range(numAA):
        codon = makeCodon()
        if codon not in ["TAA","TAG","TGA"]:
            seed+=codon
    seed+="TAA"
    return seed

seedNum = 4
for i in range(seedNum):
    length = 100
    filename = "seeds/seed"+str(i)+"len"+str(length)+".fa"
    os.makedirs(os.path.dirname(filename), exist_ok=True)
    with open(filename, "w") as out:
        out.write(makeSeed(length))
