from itertools import groupby
from itertools import (takewhile,repeat)
from Bio.Phylo.PAML import codeml
from Bio.Phylo.PAML.chi2 import cdf_chi2
from Bio.Align.Applications import MafftCommandline
from io import StringIO
from Bio import AlignIO
from Bio import SeqIO
import sys
import re
"NW_005081559.1"

def fasta_iter(fasta_name):


    fh = open(fasta_name)


    faiter = (x[1] for x in groupby(fh, lambda line: line[0] == ">"))

    for header in faiter:
        headerStr = header.__next__()[1:].strip()#Entire line, add .split[0] for just first column
        # print(header)


        seq = "".join(s.strip() for s in faiter.__next__())

        yield (headerStr, seq)
def isTrinity(header):
    if all([header[0:2] == "TR","|c" in header,"_g" in header,"_i" in header]):
        return True
    else:
        print("Sorry, we only support Trinity assemblies as of now\nExiting now")
        sys.exit()
        """
        Remove this nonsense, just return False

        """


# def find_left_right_anchor(String,pattern1,pattern2):
#     left_anchor = ""
#     right_anchor = ""
#     firstPosition = False
#     splitPattern =  String.split(pattern1)
#     if len(splitPattern) == 2:
#         for i in range(len(splitPattern)):
#             otherSplit = splitPattern[i].split(pattern2)
#             if len(otherSplit) ==1:
#
#                 if i == 0:
#                     left_anchor = splitPattern[i]
#                     #print pattern1, " is first"
#                     firstPosition = True
#
#                 else:
#                     right_anchor = splitPattern[i]
#                     #print pattern1, " is second"
#
#             else:
#                 if i == 0:
#                     left_anchor = otherSplit[1]
#                 else:
#                     right_anchor = otherSplit[0]
#     else:
#
#         sys.exit()
#     return {"left":left_anchor,"right":right_anchor,"first":firstPosition}
SAMPLES, = glob_wildcards("{sample}.fasta")
COUNTER = []
#TESTTT, = glob_wildcards("OG{sample}.fa")

#print(TESTTT)
#SAMPLES2, = glob_wildcards("all.pep.combined_{sample}.fasta")
#RESULTS, = glob_wildcards("Little/Results_{date}")
#ORTHOGROUP, = glob_wildcards("Alignments/OG{orthogroup}.fa")


#ORTHOGROUP, = glob_wildcards("Little/Results_"+RESULTS[0]+"/Alignments/OG{orthogroup}.fa")
#ORTHOGROUP, = glob_wildcards("Little/OG{orthogroup}.fa")

#place4File = "sequenceDir/"+OrthoFinderDir+"/Alignments/OG{orthogroup}.out"
#print(expand("Alignments/OG{orthogroup}.phy",orthogroup=ORTHOGROUP))
#print(RESULTS)
#print(ORTHOGROUP)
#FAMILIES, = glob_wildcards("Families/family_{fam}.fasta")
#print(FAMILIES)

rule final:
    #input:"statsfile.txt"
    input:dynamic("Families/family_{fam}_dir/family_{fam}.tree.fubar.csv")
    #input:dynamic("Families/family_{fam}_dir/M8a/tmp.txt")
    #input: dynamic("Families/family_{fam}_dir/M0/family_{fam}.mcl")
    #input: "Temp/all.pep.combined"
    #input: expand("{sample}.new_headers", sample=SAMPLES)
    #input: dynamic("Families/family_{fam}_dir/family_{fam}.codon.phylip")
    #input: expand("{sample}.fasta.clean.new_headers.transdecoder.pep",sample=SAMPLES)
    #input:"Temp/all.pep.combined"
    #input:dynamic("Families/family_{fam}.aln")
    #input:expand("{sample}.fasta.clean", sample = SAMPLES),expand("{sample}.fasta.clean.new_headers", sample = SAMPLES)
    #input:dynamic("Families/family_{fam}_dir/family_{fam}.codon.phylip")
    #input:dynamic("Families/family_{fam}.aln")
    #input:dynamic("Families/family_{fam}_dir/M01237/family_{fam}.mcl")
    #input: expand("{sample}.trinity",sample=SAMPLES)

    #input:"Families/family_3523_dir/M8_family_3523.mcl"
    #input: dynamic("Families/family_{fam}.fasta")

    #input:
    #    dynamic("Families/family_{fam}.phy.trimmed"),
    #    dynamic("Families/family_{fam}.phy")
    #input:
        #trimmedFile=dynamic("Families/family_{fam}.aln.trimmed"),
        #columnFile=dynamic("Families/family_{fam}.aln.trimmed.column_file")
    #input:dynamic("Families/family_{fam}.fasta")

    #input:expand("Families/family_{fam}.aln",fam=FAMILIES)
    #input: "Families/"
    #input:"Temp/all.pep.combined_r90_SLX.fnodes"
    #input: "Temp/all.pep.combined.blastall.out"
    #input:expand("Temp/{sample}.longestIsoform.pep.fasta", sample=SAMPLES),expand("Temp/{sample}.longestIsoform.cds",sample=SAMPLES)
#        input:"LittleAlignments/"

    #input:expand("OrthoDir/{sample}.longestIsoform.newer.fasta",sample=SAMPLES)
    #input:expand("Alignments/OG{orthogroup}.phy",orthogroup=ORTHOGROUP)

    #input: "combined.txt"

    #input:expand("Alignments/OG{orthogroup}.fa",orthogroup=ORTHOGROUP)

    #input: expand("sequenceDir/"+OrthoFinderDir+"/Alignments/OG{orthogroup}.out", orthogroup=ORTHOGROUP)

    #input: expand("sequenceDir/{sample}.longestIsoform.pep.fasta", sample=SAMPLES)
    #input:expand("all.pep.combined_{sample2}.RAXML.out.tre", sample2=SAMPLES2)
    #Aqinput:

    #input: "all.pep.combined.blastall.out"

#NOTE
"""
    Before this we need to check the headers of the fasta file, clean them up, and determine if they are from
        Trinity

    For now we will just have transdecoder 2.0 as a requirements, since only 1.0 is on bioconda, until
        I find a workaround
"""

rule cleanFasta:
    input:
        "{sample}.fasta"
    output:
        "{sample}.clean"
    run:
        sequence_iterator = fasta_iter(input[0])
        fileLength = 0
        columnCountDict={}
        wordDict = {}
        rowMembers = 1
        with open(output[0],"w") as out:
            for ff in sequence_iterator:

                headerStr, seq = ff
                min = -1
                max = 0
                for i in range(len(seq)):
                    if seq[i] not in "ATCGNatcgn":
                        if  i!= 0:
                            if min == -1:
                                min = i
                        else:
                            min = 0
                        if i > max:
                            max = i
                if min != -1 and max!= 0:
                    new_seq = seq[0:min] + seq[max+1:]
                else:
                    new_seq = seq

                allNbool = False
                if "n" in seq or "N" in seq:
                    if len(set(seq)) == 2:
                        if "N" in set(seq) and "n" in set(seq):
                            allNbool = True
                            #print(seq, "will be removed")
                    if len(set(seq)) == 1:
                        if "N" in set(seq) or "n" in set(seq):
                            #print(seq,"is just Ns")
                            allNbool = True
                if not allNbool:
                    out.write(">"+headerStr+'\n')
                    out.write(new_seq +"\n")
                    fileLength+=1
                    row = headerStr.strip().split()
                    columnCount = len(row)
                    if len(row) not in columnCountDict:

                        columnCountDict[len(row)] = 1
                    else:
                        columnCountDict[len(row)] += 1
                    try:
                        if len(columnCountDict)>rowMembers:
                            #print "columnCount has changed"
                            rowMembers+=1
                    except:
                        None
                    subString = ""
                    wordColumn = 1
                    RecentAlpha = False
                    #print line
                    for j in headerStr:
                        try:
                            if specialCharacterBool != (not j.isdigit() and not j.isalpha() and j!='-'):
                                if wordColumn not in wordDict:
                                    wordDict[wordColumn] = []
                                    wordDict[wordColumn].append(subString)
                                else:
                                    if subString not in wordDict[wordColumn]:

                                        wordDict[wordColumn].append(subString)
                                #print wordColumn, subString
                                wordColumn+=1
                                #print subString
                                subString = ""

                            specialCharacterBool= (not j.isdigit() and not j.isalpha() and j!='-')
                        except:
                            specialCharacterBool= (not j.isdigit() and not j.isalpha() and j!='-')
                        if specialCharacterBool:
                            subString+=j
                        else:
                            subString += j
                    if wordColumn not in wordDict:
                        wordDict[wordColumn] = []
                        wordDict[wordColumn].append(subString)
                    else:
                        if subString not in wordDict[wordColumn]:
                            wordDict[wordColumn].append(subString)
        pattern= ""
        numIsoformIDs = 0
        for i in wordDict.keys():
            #print len(wordDict[i])
            if len(wordDict[i]) == 1:
                pattern+=wordDict[i][0]
            else:
                if len(wordDict[i]) == fileLength:


                    pattern +="{unique_id}"
                else:
                    pattern += "{isoform_id}"
                    numIsoformIDs+=1
        print("Patern for",input[0],"is:", pattern)
        if "{isoform_id}" not in pattern:
            print("WE CANNOT DETECT ISOFORMS!!!!!!!!!")
        else:
            print("WE COULD DETECT ISOFORMS????????????")
            with open("headerPatterns.txt","a") as out:
                out.write(input[0].split('.')[0]+"@@@"+pattern+'\n')
        #sample = input[0].split('.')[0]










rule newHeaders:
    input:
        "{sample}.clean"
    output:
        "{sample}.new_headers"
    run:
        try:
            patternDict = {}
            with open("headerPatterns.txt") as f:
                for line in f:
                    row = line.strip().split("@@@")
                    patternDict[row[0]] = row[1]
            with open(output[0],"w") as out:
                pattern = patternDict[input[0].split('.')[0]]
                sequence_iterator = fasta_iter(input[0])
                for ff in sequence_iterator:

                    headerStr, seq = ff
                    #first_pattern = ""

                    if True: #replace with num {isoform} == 1
                        #print(headerStr)

                        if "{isoform_id}" in pattern.split("{unique_id}")[1]:
                            first_constant = pattern.split("{unique_id}")[0]
                            second_constant = pattern.split("{unique_id}")[1].split("{isoform_id}")[0]
                            third_constant = pattern.split("{unique_id}")[1].split("{isoform_id}")[1]

                            identifiers = re.search(first_constant+"(.*)"+second_constant+"(.*)"+third_constant,headerStr)
                            #print(identifiers)
                            new_header = identifiers.group(1) +"___" + identifiers.group(2)

                        else:
                            first_constant = pattern.split("{isoform_id}")[0]
                            second_constant = pattern.split("{isoform_id}")[1].split("{unique_id}")[0]
                            third_constant = pattern.split("{isoform_id}")[1].split("{unique_id}")[1]

                            identifiers = re.search(first_constant+"(.*)"+second_constant+"(.*)"+third_constant,headerStr)

                            new_header =  identifiers.group(2) + "___" + identifiers.group(1)

                    out.write( ">"+new_header+'\n')
                    out.write(seq+'\n')

        except:
            with open(output[0],"w") as out:
                sequence_iterator = fasta_iter(input[0])
                for ff in sequence_iterator:

                    headerStr, seq = ff

                    out.write( ">"+ headerStr +'\n')
                    out.write(seq+'\n')



        # with open(output[0], "w") as out:
        #     with open(input[0]) as f:
        #         for line in f:
        #             if line[0] == ">":
        #                 out.write(line.strip(">"))

        #"grep '^>' {input} | sed -e 's/>//g' > {output}"

rule transdecoder:
    input:
        "{sample}.new_headers"
    output:
        "{sample}.new_headers.transdecoder.pep","{sample}.new_headers.transdecoder.cds"
    shell:
        "TransDecoder.LongOrfs -t {input} -S -m 30;TransDecoder.Predict -t {input} --single_best_orf"
longIsoform_CDS_combined = {}
#THIS RULE WORKS, hopefully correctly.....

"""
From here down the transdecoder extension is wrong and needs to be changes to {sample}.transdecoder.pep

"""




rule longestIsoform:
    input:
        pep_before = expand("{sample}.new_headers.transdecoder.pep",sample=SAMPLES),
        cds_before = expand("{sample}.new_headers.transdecoder.cds",sample=SAMPLES)
    output:
        pep_after = expand("Temp/{sample}.longestIsoform.pep",sample=SAMPLES),
        cds_after = expand("Temp/{sample}.longestIsoform.cds",sample=SAMPLES)
    run:


        #print(input.pep_before)
        #print (output.pep_after)


        isoformPresent = True
        #print(input.pep_before)
        for currentFile in range(len(output.pep_after)):

            with open(output.pep_after[currentFile], "w") as out:

                longIsoform={}

                sequence_iterator = fasta_iter(input.pep_before[currentFile])
                sample = input.pep_before[currentFile].split('.')[0]
                for ff in sequence_iterator:

                    headerStr, seq = ff
                    #GeneID = headerStr.split('::')[1][:-2]
                    try:

                        GeneID=headerStr.split('___')[1].split('::')[0]
                    except:
                        reduced_header = headerStr.split()[0].split("::")[0]+headerStr.split()[0].split("::")[1]
                        new_header = reduced_header.translate ({ord(c): "_" for c in "!@#$%^&*()[]{};:,./<>?\|`~-=_+"})
                        out.write('>'+new_header+'\n')
                        out.write(seq + '\n')
                        continue
                    if GeneID not in longIsoform:
                        longIsoform[GeneID] = [len(seq),headerStr,seq]
                    else:
                        if longIsoform[GeneID][0] < len(seq):
                            longIsoform[GeneID] = [len(seq),headerStr,seq]
                for i in longIsoform.keys():
                    #print("things")
                    #print(i)
                    #print(longIsoform[i][1])

                    out.write('>'+sample+'_'+longIsoform[i][1].split("::")[0]+'\n')
                    out.write(longIsoform[i][2]+'\n')





        for currentFile in range(len(output.cds_after)):
            with open(output.cds_after[currentFile], "w") as out:
                longIsoform_CDS ={}

                sequence_iterator = fasta_iter(input.cds_before[currentFile])
                sample = input.cds_before[currentFile].split('.')[0]
                for ff in sequence_iterator:

                    headerStr, seq = ff
                    #GeneID = headerStr.split('::')[1][:-2]
                    try:

                        GeneID=headerStr.split('___')[1].split('::')[0]
                    except:
                        reduced_header = headerStr.split()[0].split("::")[0]+headerStr.split()[0].split("::")[1]
                        new_header = reduced_header.translate ({ord(c): "_" for c in "!@#$%^&*()[]{};:,./<>?\|`~-=_+"})
                        out.write('>'+new_header+'\n')
                        out.write(seq + '\n')
                        continue

                    if GeneID not in longIsoform_CDS:
                        longIsoform_CDS[GeneID] = [len(seq),headerStr,seq]
                    else:
                        if longIsoform_CDS[GeneID][0] < len(seq):
                            longIsoform_CDS[GeneID] = [len(seq),headerStr,seq]
                for i in longIsoform_CDS.keys():
                    #print("things")
                    #print(i)
                    #print(longIsoform[i][1])
                    out.write('>'+sample+'_'+longIsoform_CDS[i][1].split("::")[0]+'\n')
                    out.write(longIsoform_CDS[i][2]+'\n')
                    Header = sample+'_'+longIsoform_CDS[i][1].split("::")[0]
                    #this thing may be too unreasonably huge, but it will save time in the later rule
                    longIsoform_CDS_combined[Header]=longIsoform_CDS[i][2]


rule combine_pep:
    input:
        expand("Temp/{sample}.longestIsoform.pep",sample=SAMPLES)
    output:
        "Temp/all.pep.combined"

    run:

        with open(output[0], "w") as out:
            for i in input:
                sample = i.split('.')[0]
                for line in open(i):
                    # if ">" in line:
                    #     out.write(">"+sample+"_"+line.strip(">"))
                    # else:
                    out.write(line)



rule blastall:
    input:
        "Temp/all.pep.combined"
    output:
        "Temp/all.pep.combined.blastall.out"
    shell:
        """
        makeblastdb -in {input} -out {input}.seq.db -dbtype prot
        blastp -db {input}.seq.db -query {input} -outfmt 6 -out {output} -num_threads 13 -evalue 1E-5
        """

rule silix:
    input:
        sequence_file="Temp/all.pep.combined",
        blast_file = "Temp/all.pep.combined.blastall.out"
    output:
        "Temp/all.pep.combined_r90_SLX.fnodes"
    shell:
        "silix -r 0.9 {input.sequence_file} {input.blast_file} > {output} || true"

"""

This is the first appearance of {fam} from dynamic,

    Since not all families are kept for downstream analysis, we should only keep the ones that don't become empty after nogaps
        the empty ones are determined from mafft,so that would probably have to be in this rule under some os() thingy
            the fasta files can be written as a side effect with "EMPTYALIGNMENt" or something in the node2families
                so that the sequences are still there physically
                put in log file that these families suck

"""


#NOTE this rule made a random .fasta file that was blank, all should be .fa or .aln

rule node2families:
    input:
        node_file="Temp/all.pep.combined_r90_SLX.fnodes",
        sequence_file="Temp/all.pep.combined"
    output:
        dynamic("Families/family_{fam}.aln")
    run:
        famDict = {}
        seqDict={}
        print("opening",input.node_file)
        with open(input.node_file) as f:
            for line in f:
                row = line.split()
                if row[0] not in famDict:
                    famDict[row[0]]= [row[1]]

                else:
                    famDict[row[0]].append(row[1])

        sequence_iterator = fasta_iter(input.sequence_file)
        print("Step 2")
        for ff in sequence_iterator:
            headerStr, seq = ff

            seqDict[headerStr] = seq

        print("Step 3")
        # print(seqDict)
        # print(famDict)
        for i in famDict.keys():
            #print("Step 4",i,famDict[i])
            print(len(famDict[i])>14)
            String = "Families/family_"+i+".fa"

            print(String)

            with open(String, "w") as out:
                for j in famDict[i]:
                    out.write('>'+j+'\n')
                    out.write(seqDict[j]+'\n')
            if len(famDict[i])>14:
                print("step 5")



                mafft_cline = MafftCommandline(input=String,auto=True)
                stdout, stderr = mafft_cline()
                align = AlignIO.read(StringIO(stdout), "fasta")

                sequence={}
                alignLength = align.get_alignment_length()
                gapPos = {}

                for i in range(len(align._records)):
                    sequence[i]=""
                    number = 0
                    for j in align._records[i]:
                        sequence[i]+=j
                        if j == "-":
                            gapPos[number]= True
                        number+=1
                colsWithGaps = len(gapPos)
                if colsWithGaps < alignLength:
                    AlignOut = String.split('.')[0]+".aln"
                    print(String)
                    print("Step 6")
                    print(String.split('.')[0]+".aln")
                    print(AlignOut)
                    count = SeqIO.write(align, AlignOut, "fasta")


rule trimAln:
    input:
        "Families/family_{fam}.aln"
    output:
        trimmed_file="Families/family_{fam}.aln.trimmed",
        column_file="Families/family_{fam}.aln.trimmed.column_file"
    shell:
        "trimal -in {input} -out {output.trimmed_file} -nogaps -colnumbering > {output.column_file}"##

rule aln2phy:
    input:
        "Families/family_{fam}.aln",
        "Families/family_{fam}.aln.trimmed"
    output:
        "Families/family_{fam}.phy",
        "Families/family_{fam}.phy.trimmed"
    run:
        seq_length=0
        #print(output,"is output")
        #print(input,"is input")
        for currentFile in range(len(output)):
            print(output[currentFile],input[currentFile])

            with open(output[currentFile], "w") as out:


                sequence_iterator = fasta_iter(input[currentFile])
                first_line =True
                for ff in sequence_iterator:

                    headerStr, seq = ff
                    if first_line:
                        seq_length = len(seq)
                        num_lines = num_lines = sum(1 for line in open(input[currentFile]) if line[0]=='>')
                        out.write(str(num_lines)+" "+str(seq_length)+"\n")
                        first_line=False

                    seq_length = len(seq)
                    out.write(headerStr.strip('>')+"\t")
                    out.write(seq +"\n")

#print(longIsoform_CDS_combined)
longIsoform_CDS_combined={}
rule phy2codon:
    input:
        untrimmed="Families/family_{fam}.phy",
        column_file="Families/family_{fam}.aln.trimmed.column_file",
        nucleotide=expand("Temp/{sample}.longestIsoform.cds",sample=SAMPLES)
    output:
        "Families/family_{fam}_dir/family_{fam}.codon.phylip",
        "Families/family_{fam}_dir/family_{fam}.aln.codon"

    run:
        cut = ""
        print(input.untrimmed)
        print(input.column_file)
        print(input.nucleotide)
        print(output)
        if longIsoform_CDS_combined == {}:
            print("making cds dictionary")
            #print(input.nucleotide)
            for currentFile in input.nucleotide:
                #print(currentFile)
                #with open(output.cds_after[currentFile], "w") as out:
                    # longIsoform_CDS ={}

                sequence_iterator = fasta_iter(currentFile)
                    #sample = input.cds_before[currentFile].split('.')[0]
                for ff in sequence_iterator:

                    headerStr, seq = ff
                    GeneID = headerStr

                    if GeneID not in longIsoform_CDS_combined:
                            longIsoform_CDS_combined[GeneID] = seq
        #Open outout
        print(len(longIsoform_CDS_combined))

        with open(output[0], "w") as out:
            with open(output[1],"w") as out2:


                #Get  column cut file
                with open(input.column_file) as f:
                    for line in f:
                        cut  +=line.strip()
                    cut = cut.split(',')
                    cut = list(map(int, cut))
                #print(cut)

                #Get corresponding untrimmed Alignments, as original, line by line
                line1=True
                first_line=True
                with open(input.untrimmed) as f:
                    for line in f:
                        if line1:

                            line1=False
                            continue

                        row =line.strip().split()
                        # print("***********")
                        # print(row)
                        # print("____________")
                        original=row[1]#cds
                        header=row[0]
                        #print("Sequence:",sequence)
                        #print("Header:",header)
                        try:
                            sequence=longIsoform_CDS_combined[header]#original
                        except:
                            print(header,"not in dict")
                        CodonPos={}
                        position=0
                        codon=""
                        number=1
                        for i in sequence:

                            codon +=i
                            #print i,position%3,codon
                            if position%3==2:
                                #print codon
                                #print codonTable[codon]
                                CodonPos[number]=codon
                                number+=1
                                #protein+=codonTable[codon]
                            position +=1

                            if position%3==0:
                                #print codon
                                codon=""
                        aaPos=0
                        firstAA=True
                        alnPos=0
                        prot=""
                        trimmed=""
                        for i in original:
                            if i!="-":
                                aaPos+=1

                            if alnPos in cut:
                                prot+=i
                                if i != "-":
                                    trimmed+=CodonPos[aaPos]
                                else:
                                    trimmed+="---"
                            alnPos+=1
                        num_lines = sum(1 for line in open(input.untrimmed) )
                        if first_line:
                            out.write(str(num_lines-1) + " " + str(len(trimmed)) + '\n')
                            first_line=False
                        out.write(header+'   '+trimmed+'\n')
                        out2.write(">"+header+"\n")
                        out2.write(trimmed+"\n")
rule FastTree:
    input:
        "Families/family_{fam}.aln"
    output:
        "Families/family_{fam}_dir/family_{fam}.tree"
    shell:
        "FastTree  -nosupport {input} > {output} || true"

rule copyTreeAln:
    input:
        tree_before="Families/family_{fam}_dir/family_{fam}.tree",
        aln_before="Families/family_{fam}_dir/family_{fam}.codon.phylip"
    output:
        treeM8a= "Families/family_{fam}_dir/M8a/family_{fam}.tree",
        treeM0="Families/family_{fam}_dir/M0/family_{fam}.tree",
        treeM1="Families/family_{fam}_dir/M1/family_{fam}.tree",
        treeM2="Families/family_{fam}_dir/M2/family_{fam}.tree",
        treeM3="Families/family_{fam}_dir/M3/family_{fam}.tree",
        treeM7="Families/family_{fam}_dir/M7/family_{fam}.tree",
        treeM8="Families/family_{fam}_dir/M8/family_{fam}.tree",
        alnM8a = "Families/family_{fam}_dir/M8a/family_{fam}.codon.phylip",
        alnM0="Families/family_{fam}_dir/M0/family_{fam}.codon.phylip",
        alnM1="Families/family_{fam}_dir/M1/family_{fam}.codon.phylip",
        alnM2="Families/family_{fam}_dir/M2/family_{fam}.codon.phylip",
        alnM3="Families/family_{fam}_dir/M3/family_{fam}.codon.phylip",
        alnM7="Families/family_{fam}_dir/M7/family_{fam}.codon.phylip",
        alnM8 = "Families/family_{fam}_dir/M8/family_{fam}.codon.phylip"
    shell:
        """cp {input.aln_before} {output.alnM8a}
        cp {input.aln_before} {output.alnM0}
        cp {input.aln_before} {output.alnM1}
        cp {input.aln_before} {output.alnM2}
        cp {input.aln_before} {output.alnM3}
        cp {input.aln_before} {output.alnM7}
        cp {input.aln_before} {output.alnM8}

        cp {input.tree_before} {output.treeM8a}
        cp {input.tree_before} {output.treeM0}
        cp {input.tree_before} {output.treeM1}
        cp {input.tree_before} {output.treeM2}
        cp {input.tree_before} {output.treeM3}
        cp {input.tree_before} {output.treeM7}
        cp {input.tree_before} {output.treeM8}
        """



###############################################################
"""

for PAML rule,

    have 2 outputs, M8 and M01237
    also an out put file with the following columns
        GeneFamily  ModelComparison ChiSq D.F p-value maybeFDR
    Also,, try to generate all BEB files that exist (a lot of times they don't)
        We'll use these in the final rule to plot familes with sites of strong selection


"""






#####################################################################3

rule M0:
    input:
        "Families/family_{fam}_dir/M0/family_{fam}.tree",
        "Families/family_{fam}_dir/M0/family_{fam}.codon.phylip"
    output:
        "Families/family_{fam}_dir/M0/family_{fam}.mcl"
    run:
        COUNTER.append(True)
        M0_cml = codeml.Codeml()
        M0_cml.alignment = input[1]
        M0_cml.tree = input[0]
        M0_cml.out_file = output[0]
        M0_cml.working_dir = output[0].split('/')[:-1][0] +'/'+output[0].split('/')[:-1][1]+'/'+output[0].split('/')[:-1][2]+'/'


        M0_cml.set_options(noisy = 9)	         # 0,1,2,3,9: how much rubbish on the screen
        M0_cml.set_options(verbose = 1)	     # 1: detailed output, 0: concise output
        M0_cml.set_options(runmode = 0)	     # 0: user tree;  1: semi-automatic;  2: automatic
        M0_cml.set_options(seqtype = 1)	     # 1:codons; 2:AAs; 3:codons-->AAs
        M0_cml.set_options(CodonFreq = 2)	     # 0:1/61 each, 1:F1X4, 2:F3X4, 3:codon table
        M0_cml.set_options(clock = 0)	         # 0: no clock, unrooted tree, 1: clock, rooted tree
        M0_cml.set_options(aaDist = 0)	         # 0:equal, +:geometric; -:linear, {1-5:G1974,Miyata,c,p,v}
        M0_cml.set_options(model = 0)	         # models for codons:
        M0_cml.set_options(NSsites = [0])	     # 0:one w; 1:NearlyNeutral; 2:PositiveSelection; 3:discrete; Needs to be array
        M0_cml.set_options(icode = 0)	         # 0:standard genetic code; 1:mammalian mt; 2-10:see below
        M0_cml.set_options(Mgene = 0)	         # 0:rates, 1:separate; 2:pi, 3:kappa, 4:all
        M0_cml.set_options(fix_kappa = 0)	     # 1: kappa fixed, 0: kappa to be estimated
        M0_cml.set_options(kappa = 2)	         # initial or fixed kappa
        M0_cml.set_options(fix_omega = 0)	     # 1: omega or omega_1 fixed, 0: estimate
        M0_cml.set_options(omega = 1)	         # initial or fixed omega, for codons or codon-based AAs
        M0_cml.set_options(getSE = 0)	         # 0: don't want them, 1: want S.E.s of estimates
        M0_cml.set_options(RateAncestor = 0)	 # (0,1,2): rates (alpha>0) or ancestral states (1 or 2)
        M0_cml.set_options(Small_Diff = .45e-6) # Default value.
        M0_cml.set_options(cleandata = 0)	     # remove sites with ambiguity data (1:yes, 0:no)?
        M0_cml.set_options(fix_blength = 0)	 # 0: ignore, -1: random, 1: initial, 2: fixed


        M0_results = M0_cml.run(verbose=True)
        try:

            M0_lnL = M0_results.get("NSsites").get(0).get("lnL")
            M0_np = len(M0_results.get("NSsites").get(0).get("parameters").get("parameter list").split())
            print("@@@@@@@@@@@@@@@@@@@@")
            print(M0_lnL,M0_np,M0_cml.working_dir)
            with open(M0_cml.working_dir+"statsfile.txt","w") as out:
                out.write(M0_cml.working_dir.strip("_dir/M0").strip("Families/")+"\tM0\t"+str(M0_np)+"\t"+str(M0_lnL)+"\n")
        except:
            with open(M0_cml.working_dir+"statsfile.txt","w") as out:
                out.write(M0_cml.working_dir.strip("_dir/M0").strip("Families/")+"\tM0\tNA\tNA\n")
        # M1a_lnL = M01237_results.get("NSsites").get(1).get("lnL")
        # M1a_np = len(M01237_results.get("NSsites").get(1).get("parameters").get("parameter list").split())
        #
        # M2a_lnL = M01237_results.get("NSsites").get(2).get("lnL")
        # M2a_np = len(M01237_results.get("NSsites").get(2).get("parameters").get("parameter list").split())
        #
        # M3_lnL = M01237_results.get("NSsites").get(3).get("lnL")
        # M3_np = len(M01237_results.get("NSsites").get(3).get("parameters").get("parameter list").split())
        #
        # M7_lnL = M01237_results.get("NSsites").get(7).get("lnL")
        #         M7_np = len(M01237_results.get("NSsites").get(7).get("parameters").get("parameter list").split())
        #
        # M8_lnL = M01237_results.get("NSsites").get(8).get("lnL")
        # M8_np = len(M01237_results.get("NSsites").get(8).get("parameters").get("parameter list").split())



rule M1:
    input:
        "Families/family_{fam}_dir/M1/family_{fam}.tree",
        "Families/family_{fam}_dir/M1/family_{fam}.codon.phylip"
    output:
        "Families/family_{fam}_dir/M1/family_{fam}.mcl"
    run:
        COUNTER.append(True)
        M1_cml = codeml.Codeml()
        M1_cml.alignment = input[1]
        M1_cml.tree = input[0]
        M1_cml.out_file = output[0]
        M1_cml.working_dir = output[0].split('/')[:-1][0] +'/'+output[0].split('/')[:-1][1]+'/'+output[0].split('/')[:-1][2]+'/'


        M1_cml.set_options(noisy = 9)	         # 0,1,2,3,9: how much rubbish on the screen
        M1_cml.set_options(verbose = 1)	     # 1: detailed output, 0: concise output
        M1_cml.set_options(runmode = 0)	     # 0: user tree;  1: semi-automatic;  2: automatic
        M1_cml.set_options(seqtype = 1)	     # 1:codons; 2:AAs; 3:codons-->AAs
        M1_cml.set_options(CodonFreq = 2)	     # 0:1/61 each, 1:F1X4, 2:F3X4, 3:codon table
        M1_cml.set_options(clock = 0)	         # 0: no clock, unrooted tree, 1: clock, rooted tree
        M1_cml.set_options(aaDist = 0)	         # 0:equal, +:geometric; -:linear, {1-5:G1974,Miyata,c,p,v}
        M1_cml.set_options(model = 0)	         # models for codons:
        M1_cml.set_options(NSsites = [1])	     # 0:one w; 1:NearlyNeutral; 2:PositiveSelection; 3:discrete; Needs to be array
        M1_cml.set_options(icode = 0)	         # 0:standard genetic code; 1:mammalian mt; 2-10:see below
        M1_cml.set_options(Mgene = 0)	         # 0:rates, 1:separate; 2:pi, 3:kappa, 4:all
        M1_cml.set_options(fix_kappa = 0)	     # 1: kappa fixed, 0: kappa to be estimated
        M1_cml.set_options(kappa = 2)	         # initial or fixed kappa
        M1_cml.set_options(fix_omega = 0)	     # 1: omega or omega_1 fixed, 0: estimate
        M1_cml.set_options(omega = 1)	         # initial or fixed omega, for codons or codon-based AAs
        M1_cml.set_options(getSE = 0)	         # 0: don't want them, 1: want S.E.s of estimates
        M1_cml.set_options(RateAncestor = 0)	 # (0,1,2): rates (alpha>0) or ancestral states (1 or 2)
        M1_cml.set_options(Small_Diff = .45e-6) # Default value.
        M1_cml.set_options(cleandata = 0)	     # remove sites with ambiguity data (1:yes, 0:no)?
        M1_cml.set_options(fix_blength = 0)	 # 0: ignore, -1: random, 1: initial, 2: fixed


        M1_results = M1_cml.run(verbose=True)
        try:

            M1_lnL = M1_results.get("NSsites").get(1).get("lnL")
            M1_np = len(M1_results.get("NSsites").get(1).get("parameters").get("parameter list").split())
            print("@@@@@@@@@@@@@@@@@@@@")
            print(M1_lnL,M1_np,M1_cml.working_dir)
            with open(M1_cml.working_dir+"statsfile.txt","w") as out:
                out.write(M1_cml.working_dir.strip("_dir/M1").strip("Families/")+"\tM1\t"+str(M1_np)+"\t"+str(M1_lnL)+"\n")
        except:
            with open(M1_cml.working_dir+"statsfile.txt","w") as out:
                out.write(M1_cml.working_dir.strip("_dir/M1").strip("Families/")+"\tM1\tNA\tNA\n")


rule M2:
    input:
        "Families/family_{fam}_dir/M2/family_{fam}.tree",
        "Families/family_{fam}_dir/M2/family_{fam}.codon.phylip"
    output:
        "Families/family_{fam}_dir/M2/family_{fam}.mcl"
    run:
        COUNTER.append(True)
        M2_cml = codeml.Codeml()
        M2_cml.alignment = input[1]
        M2_cml.tree = input[0]
        M2_cml.out_file = output[0]
        M2_cml.working_dir = output[0].split('/')[:-1][0] +'/'+output[0].split('/')[:-1][1]+'/'+output[0].split('/')[:-1][2]+'/'


        M2_cml.set_options(noisy = 9)	         # 0,1,2,3,9: how much rubbish on the screen
        M2_cml.set_options(verbose = 1)	     # 1: detailed output, 0: concise output
        M2_cml.set_options(runmode = 0)	     # 0: user tree;  1: semi-automatic;  2: automatic
        M2_cml.set_options(seqtype = 1)	     # 1:codons; 2:AAs; 3:codons-->AAs
        M2_cml.set_options(CodonFreq = 2)	     # 0:1/61 each, 1:F1X4, 2:F3X4, 3:codon table
        M2_cml.set_options(clock = 0)	         # 0: no clock, unrooted tree, 1: clock, rooted tree
        M2_cml.set_options(aaDist = 0)	         # 0:equal, +:geometric; -:linear, {1-5:G1974,Miyata,c,p,v}
        M2_cml.set_options(model = 0)	         # models for codons:
        M2_cml.set_options(NSsites = [2])	     # 0:one w; 1:NearlyNeutral; 2:PositiveSelection; 3:discrete; Needs to be array
        M2_cml.set_options(icode = 0)	         # 0:standard genetic code; 1:mammalian mt; 2-10:see below
        M2_cml.set_options(Mgene = 0)	         # 0:rates, 1:separate; 2:pi, 3:kappa, 4:all
        M2_cml.set_options(fix_kappa = 0)	     # 1: kappa fixed, 0: kappa to be estimated
        M2_cml.set_options(kappa = 2)	         # initial or fixed kappa
        M2_cml.set_options(fix_omega = 0)	     # 1: omega or omega_1 fixed, 0: estimate
        M2_cml.set_options(omega = 1)	         # initial or fixed omega, for codons or codon-based AAs
        M2_cml.set_options(getSE = 0)	         # 0: don't want them, 1: want S.E.s of estimates
        M2_cml.set_options(RateAncestor = 0)	 # (0,1,2): rates (alpha>0) or ancestral states (1 or 2)
        M2_cml.set_options(Small_Diff = .45e-6) # Default value.
        M2_cml.set_options(cleandata = 0)	     # remove sites with ambiguity data (1:yes, 0:no)?
        M2_cml.set_options(fix_blength = 0)	 # 0: ignore, -1: random, 1: initial, 2: fixed


        M2_results = M2_cml.run(verbose=True)
        try:

            M2_lnL = M2_results.get("NSsites").get(2).get("lnL")
            M2_np = len(M2_results.get("NSsites").get(2).get("parameters").get("parameter list").split())
            print("@@@@@@@@@@@@@@@@@@@@")
            print(M2_lnL,M2_np,M2_cml.working_dir)
            with open(M2_cml.working_dir+"statsfile.txt","w") as out:
                out.write(M2_cml.working_dir.strip("_dir/M2").strip("Families/")+"\tM2\t"+str(M2_np)+"\t"+str(M2_lnL)+"\n")
        except:
            with open(M2_cml.working_dir+"statsfile.txt","w") as out:
                out.write(M2_cml.working_dir.strip("_dir/M2").strip("Families/")+"\tM2\tNA\tNA\n")

rule M3:
    input:
        "Families/family_{fam}_dir/M3/family_{fam}.tree",
        "Families/family_{fam}_dir/M3/family_{fam}.codon.phylip"
    output:
        "Families/family_{fam}_dir/M3/family_{fam}.mcl"
    run:
        COUNTER.append(True)
        M3_cml = codeml.Codeml()
        M3_cml.alignment = input[1]
        M3_cml.tree = input[0]
        M3_cml.out_file = output[0]
        M3_cml.working_dir = output[0].split('/')[:-1][0] +'/'+output[0].split('/')[:-1][1]+'/'+output[0].split('/')[:-1][2]+'/'


        M3_cml.set_options(noisy = 9)	         # 0,1,2,3,9: how much rubbish on the screen
        M3_cml.set_options(verbose = 1)	     # 1: detailed output, 0: concise output
        M3_cml.set_options(runmode = 0)	     # 0: user tree;  1: semi-automatic;  2: automatic
        M3_cml.set_options(seqtype = 1)	     # 1:codons; 2:AAs; 3:codons-->AAs
        M3_cml.set_options(CodonFreq = 2)	     # 0:1/61 each, 1:F1X4, 2:F3X4, 3:codon table
        M3_cml.set_options(clock = 0)	         # 0: no clock, unrooted tree, 1: clock, rooted tree
        M3_cml.set_options(aaDist = 0)	         # 0:equal, +:geometric; -:linear, {1-5:G1974,Miyata,c,p,v}
        M3_cml.set_options(model = 0)	         # models for codons:
        M3_cml.set_options(NSsites = [3])	     # 0:one w; 1:NearlyNeutral; 2:PositiveSelection; 3:discrete; Needs to be array
        M3_cml.set_options(icode = 0)	         # 0:standard genetic code; 1:mammalian mt; 2-10:see below
        M3_cml.set_options(Mgene = 0)	         # 0:rates, 1:separate; 2:pi, 3:kappa, 4:all
        M3_cml.set_options(fix_kappa = 0)	     # 1: kappa fixed, 0: kappa to be estimated
        M3_cml.set_options(kappa = 2)	         # initial or fixed kappa
        M3_cml.set_options(fix_omega = 0)	     # 1: omega or omega_1 fixed, 0: estimate
        M3_cml.set_options(omega = 1)	         # initial or fixed omega, for codons or codon-based AAs
        M3_cml.set_options(getSE = 0)	         # 0: don't want them, 1: want S.E.s of estimates
        M3_cml.set_options(RateAncestor = 0)	 # (0,1,2): rates (alpha>0) or ancestral states (1 or 2)
        M3_cml.set_options(Small_Diff = .45e-6) # Default value.
        M3_cml.set_options(cleandata = 0)	     # remove sites with ambiguity data (1:yes, 0:no)?
        M3_cml.set_options(fix_blength = 0)	 # 0: ignore, -1: random, 1: initial, 2: fixed


        M3_results = M3_cml.run(verbose=True)
        try:

            M3_lnL = M3_results.get("NSsites").get(3).get("lnL")
            M3_np = len(M3_results.get("NSsites").get(3).get("parameters").get("parameter list").split())
            print("@@@@@@@@@@@@@@@@@@@@")
            print(M3_lnL,M3_np,M3_cml.working_dir)
            with open(M3_cml.working_dir+"statsfile.txt","w") as out:
                out.write(M3_cml.working_dir.strip("_dir/M3").strip("Families/")+"\tM3\t"+str(M3_np)+"\t"+str(M3_lnL)+"\n")
        except:
            with open(M3_cml.working_dir+"statsfile.txt","w") as out:
                out.write(M3_cml.working_dir.strip("_dir/M3").strip("Families/")+"\tM3\tNA\tNA\n")

rule M7:
    input:
        "Families/family_{fam}_dir/M7/family_{fam}.tree",
        "Families/family_{fam}_dir/M7/family_{fam}.codon.phylip"
    output:
        "Families/family_{fam}_dir/M7/family_{fam}.mcl"
    run:
        COUNTER.append(True)
        M7_cml = codeml.Codeml()
        M7_cml.alignment = input[1]
        M7_cml.tree = input[0]
        M7_cml.out_file = output[0]
        M7_cml.working_dir = output[0].split('/')[:-1][0] +'/'+output[0].split('/')[:-1][1]+'/'+output[0].split('/')[:-1][2]+'/'


        M7_cml.set_options(noisy = 9)	         # 0,1,2,3,9: how much rubbish on the screen
        M7_cml.set_options(verbose = 1)	     # 1: detailed output, 0: concise output
        M7_cml.set_options(runmode = 0)	     # 0: user tree;  1: semi-automatic;  2: automatic
        M7_cml.set_options(seqtype = 1)	     # 1:codons; 2:AAs; 3:codons-->AAs
        M7_cml.set_options(CodonFreq = 2)	     # 0:1/61 each, 1:F1X4, 2:F3X4, 3:codon table
        M7_cml.set_options(clock = 0)	         # 0: no clock, unrooted tree, 1: clock, rooted tree
        M7_cml.set_options(aaDist = 0)	         # 0:equal, +:geometric; -:linear, {1-5:G1974,Miyata,c,p,v}
        M7_cml.set_options(model = 0)	         # models for codons:
        M7_cml.set_options(NSsites = [7])	     # 0:one w; 1:NearlyNeutral; 2:PositiveSelection; 3:discrete; Needs to be array
        M7_cml.set_options(icode = 0)	         # 0:standard genetic code; 1:mammalian mt; 2-10:see below
        M7_cml.set_options(Mgene = 0)	         # 0:rates, 1:separate; 2:pi, 3:kappa, 4:all
        M7_cml.set_options(fix_kappa = 0)	     # 1: kappa fixed, 0: kappa to be estimated
        M7_cml.set_options(kappa = 2)	         # initial or fixed kappa
        M7_cml.set_options(fix_omega = 0)	     # 1: omega or omega_1 fixed, 0: estimate
        M7_cml.set_options(omega = 1)	         # initial or fixed omega, for codons or codon-based AAs
        M7_cml.set_options(getSE = 0)	         # 0: don't want them, 1: want S.E.s of estimates
        M7_cml.set_options(RateAncestor = 0)	 # (0,1,2): rates (alpha>0) or ancestral states (1 or 2)
        M7_cml.set_options(Small_Diff = .45e-6) # Default value.
        M7_cml.set_options(cleandata = 0)	     # remove sites with ambiguity data (1:yes, 0:no)?
        M7_cml.set_options(fix_blength = 0)	 # 0: ignore, -1: random, 1: initial, 2: fixed


        M7_results = M7_cml.run(verbose=True)
        try:

            M7_lnL = M7_results.get("NSsites").get(7).get("lnL")
            M7_np = len(M7_results.get("NSsites").get(7).get("parameters").get("parameter list").split())
            print("@@@@@@@@@@@@@@@@@@@@")
            print(M7_lnL,M7_np,M7_cml.working_dir)
            with open(M7_cml.working_dir+"statsfile.txt","w") as out:
                out.write(M7_cml.working_dir.strip("_dir/M7").strip("Families/")+"\tM7\t"+str(M7_np)+"\t"+str(M7_lnL)+"\n")
        except:
            with open(M7_cml.working_dir+"statsfile.txt","w") as out:
                out.write(M7_cml.working_dir.strip("_dir/M7").strip("Families/")+"\tM7\tNA\tNA\n")

rule M8:
    input:
        "Families/family_{fam}_dir/M8/family_{fam}.tree",
        "Families/family_{fam}_dir/M8/family_{fam}.codon.phylip"
    output:
        "Families/family_{fam}_dir/M8/family_{fam}.mcl"
    run:
        COUNTER.append(True)
        M8_cml = codeml.Codeml()
        M8_cml.alignment = input[1]
        M8_cml.tree = input[0]
        M8_cml.out_file = output[0]
        M8_cml.working_dir = output[0].split('/')[:-1][0] +'/'+output[0].split('/')[:-1][1]+'/'+output[0].split('/')[:-1][2]+'/'


        M8_cml.set_options(noisy = 9)	         # 0,1,2,3,9: how much rubbish on the screen
        M8_cml.set_options(verbose = 1)	     # 1: detailed output, 0: concise output
        M8_cml.set_options(runmode = 0)	     # 0: user tree;  1: semi-automatic;  2: automatic
        M8_cml.set_options(seqtype = 1)	     # 1:codons; 2:AAs; 3:codons-->AAs
        M8_cml.set_options(CodonFreq = 2)	     # 0:1/61 each, 1:F1X4, 2:F3X4, 3:codon table
        M8_cml.set_options(clock = 0)	         # 0: no clock, unrooted tree, 1: clock, rooted tree
        M8_cml.set_options(aaDist = 0)	         # 0:equal, +:geometric; -:linear, {1-5:G1974,Miyata,c,p,v}
        M8_cml.set_options(model = 0)	         # models for codons:
        M8_cml.set_options(NSsites = [8])	     # 0:one w; 1:NearlyNeutral; 2:PositiveSelection; 3:discrete; Needs to be array
        M8_cml.set_options(icode = 0)	         # 0:standard genetic code; 1:mammalian mt; 2-10:see below
        M8_cml.set_options(Mgene = 0)	         # 0:rates, 1:separate; 2:pi, 3:kappa, 4:all
        M8_cml.set_options(fix_kappa = 0)	     # 1: kappa fixed, 0: kappa to be estimated
        M8_cml.set_options(kappa = 2)	         # initial or fixed kappa
        M8_cml.set_options(fix_omega = 0)	     # 1: omega or omega_1 fixed, 0: estimate
        M8_cml.set_options(omega = 1)	         # initial or fixed omega, for codons or codon-based AAs
        M8_cml.set_options(getSE = 0)	         # 0: don't want them, 1: want S.E.s of estimates
        M8_cml.set_options(RateAncestor = 0)	 # (0,1,2): rates (alpha>0) or ancestral states (1 or 2)
        M8_cml.set_options(Small_Diff = .45e-6) # Default value.
        M8_cml.set_options(cleandata = 0)	     # remove sites with ambiguity data (1:yes, 0:no)?
        M8_cml.set_options(fix_blength = 0)	 # 0: ignore, -1: random, 1: initial, 2: fixed


        M8_results = M8_cml.run(verbose=True)
        try:

            M8_lnL = M8_results.get("NSsites").get(8).get("lnL")
            M8_np = len(M8_results.get("NSsites").get(8).get("parameters").get("parameter list").split())
            print("@@@@@@@@@@@@@@@@@@@@")
            print(M8_lnL,M8_np,M8_cml.working_dir)
            with open(M8_cml.working_dir+"statsfile.txt","w") as out:
                out.write(M8_cml.working_dir.strip("_dir/M8").strip("Families/")+"\tM8\t"+str(M8_np)+"\t"+str(M8_lnL)+"\n")
        except:
            with open(M8_cml.working_dir+"statsfile.txt","w") as out:
                out.write(M8_cml.working_dir.strip("_dir/M8").strip("Families/")+"\tM8\tNA\tNA\n")






rule M8a:
    input:
        "Families/family_{fam}_dir/M8a/family_{fam}.tree",
        "Families/family_{fam}_dir/M8a/family_{fam}.codon.phylip"
    output:
        "Families/family_{fam}_dir/M8a/family_{fam}.mcl"
    run:
        COUNTER.append(True)
        M8a_cml = codeml.Codeml()
        M8a_cml.alignment = input[1]
        M8a_cml.tree = input[0]
        M8a_cml.out_file = output[0]
        M8a_cml.working_dir = output[0].split('/')[:-1][0] +'/'+output[0].split('/')[:-1][1]+'/'+output[0].split('/')[:-1][2]+'/'


        M8a_cml.set_options(noisy = 9)	         # 0,1,2,3,9: how much rubbish on the screen
        M8a_cml.set_options(verbose = 1)	     # 1: detailed output, 0: concise output
        M8a_cml.set_options(runmode = 0)	     # 0: user tree;  1: semi-automatic;  2: automatic
        M8a_cml.set_options(seqtype = 1)	     # 1:codons; 2:AAs; 3:codons-->AAs
        M8a_cml.set_options(CodonFreq = 2)	     # 0:1/61 each, 1:F1X4, 2:F3X4, 3:codon table
        M8a_cml.set_options(clock = 0)	         # 0: no clock, unrooted tree, 1: clock, rooted tree
        M8a_cml.set_options(aaDist = 0)	         # 0:equal, +:geometric; -:linear, {1-5:G1974,Miyata,c,p,v}
        M8a_cml.set_options(model = 0)	         # models for codons:
        M8a_cml.set_options(NSsites = [8])	     # 0:one w; 1:NearlyNeutral; 2:PositiveSelection; 3:discrete; Needs to be array
        M8a_cml.set_options(icode = 0)	         # 0:standard genetic code; 1:mammalian mt; 2-10:see below
        M8a_cml.set_options(Mgene = 0)	         # 0:rates, 1:separate; 2:pi, 3:kappa, 4:all
        M8a_cml.set_options(fix_kappa = 0)	     # 1: kappa fixed, 0: kappa to be estimated
        M8a_cml.set_options(kappa = 2)	         # initial or fixed kappa
        M8a_cml.set_options(fix_omega = 1)	     # 1: omega or omega_1 fixed, 0: estimate
        M8a_cml.set_options(omega = 1)	         # initial or fixed omega, for codons or codon-based AAs
        M8a_cml.set_options(getSE = 0)	         # 0: don't want them, 1: want S.E.s of estimates
        M8a_cml.set_options(RateAncestor = 0)	 # (0,1,2): rates (alpha>0) or ancestral states (1 or 2)
        M8a_cml.set_options(Small_Diff = .45e-6) # Default value.
        M8a_cml.set_options(cleandata = 0)	     # remove sites with ambiguity data (1:yes, 0:no)?
        M8a_cml.set_options(fix_blength = 0)	 # 0: ignore, -1: random, 1: initial, 2: fixed


        M8a_results=M8a_cml.run(verbose=True)
        try:

            M8a_lnL = M8a_results.get("NSsites").get(8).get("lnL")
            M8a_np = len(M8a_results.get("NSsites").get(8).get("parameters").get("parameter list").split())
            print("@@@@@@@@@@@@@@@@@@@@")
            print(M8a_lnL,M8a_np,M8a_cml.working_dir+"statsfile.txt")
            with open(M8a_cml.working_dir+"statsfile.txt","w") as out:
                out.write(M8a_cml.working_dir.strip("_dir/M8a").strip("Families/")+"\tM8a\t"+str(M8a_np)+"\t"+str(M8a_lnL)+"\n")
        except:
            with open(M8a_cml.working_dir+"statsfile.txt","w") as out:
                out.write(M8a_cml.working_dir.strip("_dir/M8a").strip("Families/")+"\tM8a\tNA\tNA\n")


rule ChiSq:
    input:
        "Families/family_{fam}_dir/M0/family_{fam}.mcl",
        "Families/family_{fam}_dir/M1/family_{fam}.mcl",
        "Families/family_{fam}_dir/M2/family_{fam}.mcl",
        "Families/family_{fam}_dir/M3/family_{fam}.mcl",
        "Families/family_{fam}_dir/M7/family_{fam}.mcl",
        "Families/family_{fam}_dir/M8/family_{fam}.mcl",
        "Families/family_{fam}_dir/M8a/family_{fam}.mcl"
    output:
        "Families/family_{fam}_dir/M0/tmp.txt",
        "Families/family_{fam}_dir/M1/tmp.txt",
        "Families/family_{fam}_dir/M2/tmp.txt",
        "Families/family_{fam}_dir/M3/tmp.txt",
        "Families/family_{fam}_dir/M7/tmp.txt",
        "Families/family_{fam}_dir/M8/tmp.txt",
        "Families/family_{fam}_dir/M8a/tmp.txt"
    run:
        #working_dir = input[0].split('/')[:-1][0] +'/'+input[0].split('/')[:-1][1]+'/'+input[0].split('/')[:-1][2]+'/'
        print("&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&")
        print("HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH")
        print(COUNTER)
        #print(working_dir)
        models = ["M0","M1","M2","M3","M7","M8","M8a"]
        with open("finalStatsfile.txt","w") as out:

            for i in output:
                with open(i.replace("tmp","statsfile")) as f:
                    for line in f:
                        out.write(line)
                with open(i, "w") as tmp:
                    tmp.write("")
        with open("FUBAR.bf","w") as out:
            string = """
            RequireVersion  ("2.11");
            _cachingOK = 1;

            ExecuteAFile (Join(DIRECTORY_SEPARATOR,{{HYPHY_LIB_DIRECTORY[0][Abs(HYPHY_LIB_DIRECTORY)-2],"TemplateBatchFiles","TemplateModels","chooseGeneticCode.def"}}));
            LoadFunctionLibrary ("GrabBag");
            LoadFunctionLibrary ("ReadDelimitedFiles");
            _runAsFunctionLibrary = 0;
            ExecuteAFile (Join(DIRECTORY_SEPARATOR,{{HYPHY_LIB_DIRECTORY[0][Abs(HYPHY_LIB_DIRECTORY)-2],"TemplateBatchFiles","_MFReader_.ibf"}}));

            filePaths = {"Base": LAST_FILE_PATH,
                         "Nucleotide fit suffix": ".gtr_fit",
                         "Codon fit suffix": ".codon_fit",
                         "Grid information": ".grid_info",
                         "MCMC samples": ".samples",
                         "Output": ".fubar.csv",
                         "SimGrid": ".sim_grid_info",
                         "SimFitFile": ".sim_codon_fit"};

            fprintf (stdout, "\n\nFUBAR will write intermediate and result files to\n", filePaths["Base"], ".extension\n\n");


            //----------------------------------------------------------------------------
            // PHASE 1: nucleotide fit
            //----------------------------------------------------------------------------

            _fubarNucFitLocation = filePaths["Base"] + filePaths["Nucleotide fit suffix"];

            if (_cachingOK && !_fubarNucFitLocation) {
            // file exists
                 fprintf (stdout, "[CACHED] FUBAR found the self-contained nucleotide fit file at ", _fubarNucFitLocation, "\n");
            }
            else
            {
                _cachingOK = 0;
                ExecuteAFile (Join(DIRECTORY_SEPARATOR,{{PATH_TO_CURRENT_BF[0][Abs(PATH_TO_CURRENT_BF)-2],"FUBAR_HBL","FUBAR_PHASE_1.bf"}}), {"0" : _fubarNucFitLocation});
                fprintf (stdout, "[DIAGNOSTIC] FUBAR wrote the self-contained nucleotide fit file to ", _fubarNucFitLocation, "\n");
            }
            fprintf (stdout, "\n\n");

            _fubarCodonFitLocation = filePaths["Base"] + filePaths["Codon fit suffix"];
            _fubarGridInfoLocation = filePaths["Base"] + filePaths["Grid information"];

            if (_cachingOK && !_fubarGridInfoLocation && !_fubarCodonFitLocation) {
                 fprintf (stdout, "[CACHED] FUBAR found the self-contained codon fit file at ", _fubarCodonFitLocation, "\n");
                 fprintf (stdout, "[CACHED] FUBAR found the site likelihoods file at ", _fubarGridInfoLocation, "\n");
            }
            else
            {

                _cachingOK = 0;
                _grid_points = prompt_for_a_value ("Number of grid points per dimension (total number is D^2)",20,5,50,1);
                fprintf (stdout, "[DIAGNOSTIC] FUBAR will use a ", _grid_points , "X", _grid_points, " grid\n");

                ExecuteAFile (Join(DIRECTORY_SEPARATOR,{{PATH_TO_CURRENT_BF[0][Abs(PATH_TO_CURRENT_BF)-2],"FUBAR_HBL","FUBAR_PHASE_2.bf"}}), {"0" : _fubarNucFitLocation,
                                                                                                                                             "1" : _fubarCodonFitLocation,
                                                                                                                                             "2" : _fubarGridInfoLocation,
                                                                                                                                             "3" : "" + _grid_points});
                fprintf (stdout, "[DIAGNOSTIC] FUBAR wrote the self-contained codon fit file to ", _fubarCodonFitLocation, "\n");
                fprintf (stdout, "[DIAGNOSTIC] FUBAR wrote the the site likelihoods file to ", _fubarGridInfoLocation, "\n");
            }
            printf (stdout, "\n\n");

            _fubarMCMCSamplesLocation = filePaths["Base"] + filePaths["MCMC samples"];

            if (_cachingOK && !_fubarMCMCSamplesLocation) {
                 fscanf (_fubarMCMCSamplesLocation, "Number", _fubarChainCount);
                 fprintf (stdout, "[CACHED] FUBAR found the MCMC samples based on ", _fubarChainCount, " chains at ", _fubarMCMCSamplesLocation, "\n");
            }
            else
            {
                _cachingOK = 0;
                _fubarChainCount = prompt_for_a_value ("Number of MCMC chains to run",5,2,20,1);
                fprintf (stdout, "[DIAGNOSTIC] FUBAR will use run ", _fubarChainCount, " independent chains\n");

                _fubarChainLength  = prompt_for_a_value ("The length of each chain",2000000,500000,100000000,1);
                fprintf (stdout, "[DIAGNOSTIC] FUBAR will run the chains for ", _fubarChainLength, " steps\n");
                _fubarChainBurnin  = prompt_for_a_value ("Discard this many samples as burn-in",_fubarChainLength$2,_fubarChainLength$20,_fubarChainLength*95$100,1);
                fprintf (stdout, "[DIAGNOSTIC] FUBAR will run discard ", _fubarChainBurnin, " steps as burn-in\n");
                _fubarTotalSamples = prompt_for_a_value ("How many samples should be drawn from each chain",100,10,_fubarChainLength-_fubarChainBurnin,1);
                fprintf (stdout, "[DIAGNOSTIC] FUBAR will run thin each chain down to ", _fubarTotalSamples, " samples\n");
                _fubarPriorShape = prompt_for_a_value ("The concentration parameter of the Dirichlet prior",0.5,0.001,1,0);
                fprintf (stdout, "[DIAGNOSTIC] FUBAR will use the Dirichlet prior concentration parameter of ", _fubarPriorShape, "\n");

                ExecuteAFile (Join(DIRECTORY_SEPARATOR,{{PATH_TO_CURRENT_BF[0][Abs(PATH_TO_CURRENT_BF)-2],"FUBAR_HBL","FUBAR_PHASE_3.bf"}}), {"0" : _fubarMCMCSamplesLocation,
                                                                                                                                             "1" : _fubarGridInfoLocation,
                                                                                                                                             "2" : "" + _fubarChainCount,
                                                                                                                                             "3" : "" + _fubarChainLength,
                                                                                                                                             "4" : "" + _fubarChainBurnin,
                                                                                                                                             "5" : "" + _fubarTotalSamples,
                                                                                                                                             "6" : "" + _fubarPriorShape
                                                                                                                                              });
            fprintf (stdout, "\n[DIAGNOSTIC] FUBAR wrote samples from ", _fubarChainCount, " independent chains to ", _fubarMCMCSamplesLocation, "[0-", _fubarChainCount-1, "]\n");
            }
            fprintf (stdout, "\n\n");

            _fubarResultLocation = filePaths["Base"] + filePaths["Output"];
            _fubarSimGrid        = filePaths["Base"] + filePaths["SimGrid"];
            _fubarSimFitFile     = filePaths["Base"] + filePaths["SimFitFile"];

            _fubar_do_simulations = 0;

            if (_cachingOK && !_fubarResultLocation && (_fubar_do_simulations == 0 || (!_fubarSimGrid && !_fubarSimFitFile))) {
                 fprintf (stdout, "[CACHED] FUBAR found the results file at ",_fubarResultLocation  ,"\n");
            }
            else
            {


                ExecuteAFile (Join(DIRECTORY_SEPARATOR,{{PATH_TO_CURRENT_BF[0][Abs(PATH_TO_CURRENT_BF)-2],"FUBAR_HBL","FUBAR_PHASE_4.bf"}}), {"0" : _fubarNucFitLocation,
                                                                                                                                             "1" : _fubarGridInfoLocation,
                                                                                                                                             "2" : _fubarMCMCSamplesLocation,
                                                                                                                                             "3" : "" + _fubarChainCount,
                                                                                                                                             "4" : _fubarResultLocation,
                                                                                                                                             "5" : _fubarSimFitFile,
                                                                                                                                             "6" : _fubarSimGrid,
                                                                                                                                             "7" : _fubarCodonFitLocation
                                                                                                                                              });



                fprintf (stdout, "\n[DIAGNOSTIC] FUBAR wrote the results of its analysis to ", _fubarResultLocation, "\n");
                if (_fubar_do_simulations) {
                    fprintf (stdout, "[DIAGNOSTIC] FUBAR wrote FDR simulation data to ", _fubarSimFitFile, "\n");
                    fprintf (stdout, "[DIAGNOSTIC] FUBAR wrote FDR grid information to ", _fubarSimFitFile, "\n");
                }
            }
            fubar_data = (ReadCSVTable (_fubarResultLocation, 1))[1]%4;

            ExecuteAFile (Join(DIRECTORY_SEPARATOR,{{PATH_TO_CURRENT_BF[0][Abs(PATH_TO_CURRENT_BF)-2],"FUBAR_HBL","FUBAR_tools.ibf"}}));

            fprintf (stdout, "\n[RESULTS] At posterior probability >= 0.9 ");

            idx = Rows(fubar_data);
            mean_pp = 0;

            p_i = {};

            while (fubar_data[idx-1][4] >= 0.9 && idx > 0) {
                mean_pp += (1-fubar_data[idx-1][4]);
                p_i + (1-fubar_data[idx-1][4]);
                idx += -1;

            }

            if (idx == Rows(fubar_data) ) {
                fprintf (stdout, "there were no sites under diversifying positive selection\n");
            } else {
                detected = Rows(fubar_data)-idx;
                ci = computeENFP_CI (p_i, 0.05);
                fprintf (stdout, "there were ", detected, " sites under diversifying positive selection, of which ", Format (mean_pp, 5,2), " [", ci[0], " - ", ci[1], "] are expected to be false positives.\n");
                _fubar_did_simulations = Columns(fubar_data) > 9;
                if (_fubar_did_simulations) {
                    fprintf (stdout, "\nCodon\tProb[dN/dS>1]\tEBF[dN/dS]>1\tPSRF\tN_eff\tFDR");
                    for (idx2 = Rows(fubar_data)-1; idx2 >= idx; idx2 += -1) {
                        fprintf (stdout, "\n", fubar_data[idx2][0], "\t",  fubar_data[idx2][4], "\t",  fubar_data[idx2][6], "\t", fubar_data[idx2][7], "\t",  fubar_data[idx2][8], "\t",  fubar_data[idx2][9]);
                    }
                } else {
                    fprintf (stdout, "\nCodon\tProb[dN/dS>1]\tEBF[dN/dS]>1\tPSRF\tN_eff");
                    for (idx2 = Rows(fubar_data)-1; idx2 >= idx; idx2 += -1) {
                        fprintf (stdout, "\n", fubar_data[idx2][0], "\t",  fubar_data[idx2][4], "\t",  fubar_data[idx2][6], "\t", fubar_data[idx2][7], "\t",  fubar_data[idx2][8]);
                    }
                }
                fprintf (stdout, "\n");
            """
            out.write(string)
rule FUBAR:
    input:
        tmp="Families/family_{fam}_dir/M8a/tmp.txt",
        align="Families/family_{fam}_dir/family_{fam}.aln.codon",
        tree="Families/family_{fam}_dir/family_{fam}.tree"
    output:
        "Families/family_{fam}_dir/family_{fam}.tree.fubar.csv"
    shell:
        "(echo 1; echo 1;echo {input.align}; echo {input.tree}; echo 20;echo echo 5; echo 2000000; echo 1000000;echo 100;echo 0.5 )|HYPHYMP FUBAR.bf"

























#     """
# rule makeCodmlFile:
#     input:
#         M01237_tree="Families/family_{fam}_dir/M01237/family_{fam}.tree",
#         M01237_codonAlignment = "Families/family_{fam}_dir/M01237/family_{fam}.codon.phylip",
#         M8_tree = "Families/family_{fam}_dir/M01237/family_{fam}.tree",
#         M8_codonAlignment = "Families/family_{fam}_dir/M01237/family_{fam}.codon.phylip"
#     output:
#         "Families/family_{fam}_dir/M8/family_{fam}.mcl","Families/family_{fam}_dir/M01237/family_{fam}.mcl"
#     run:
#
#         M8_cml = codeml.Codeml()
#         M8_cml.alignment = input.M8_codonAlignment
#         M8_cml.tree = input.M8_tree
#         M8_cml.out_file = output[0]
#         M8_cml.working_dir = output[0].split('/')[:-1][0] +'/'+output[0].split('/')[:-1][1]+'/'+output[0].split('/')[:-1][2]+'/'
#
#
#         M8_cml.set_options(noisy = 9)	         # 0,1,2,3,9: how much rubbish on the screen
#         M8_cml.set_options(verbose = 1)	     # 1: detailed output, 0: concise output
#         M8_cml.set_options(runmode = 0)	     # 0: user tree;  1: semi-automatic;  2: automatic
#         M8_cml.set_options(seqtype = 1)	     # 1:codons; 2:AAs; 3:codons-->AAs
#         M8_cml.set_options(CodonFreq = 2)	     # 0:1/61 each, 1:F1X4, 2:F3X4, 3:codon table
#         M8_cml.set_options(clock = 0)	         # 0: no clock, unrooted tree, 1: clock, rooted tree
#         M8_cml.set_options(aaDist = 0)	         # 0:equal, +:geometric; -:linear, {1-5:G1974,Miyata,c,p,v}
#         M8_cml.set_options(model = 0)	         # models for codons:
#         M8_cml.set_options(NSsites = [8])	     # 0:one w; 1:NearlyNeutral; 2:PositiveSelection; 3:discrete; Needs to be array
#         M8_cml.set_options(icode = 0)	         # 0:standard genetic code; 1:mammalian mt; 2-10:see below
#         M8_cml.set_options(Mgene = 0)	         # 0:rates, 1:separate; 2:pi, 3:kappa, 4:all
#         M8_cml.set_options(fix_kappa = 0)	     # 1: kappa fixed, 0: kappa to be estimated
#         M8_cml.set_options(kappa = 2)	         # initial or fixed kappa
#         M8_cml.set_options(fix_omega = 1)	     # 1: omega or omega_1 fixed, 0: estimate
#         M8_cml.set_options(omega = 1)	         # initial or fixed omega, for codons or codon-based AAs
#         M8_cml.set_options(getSE = 0)	         # 0: don't want them, 1: want S.E.s of estimates
#         M8_cml.set_options(RateAncestor = 0)	 # (0,1,2): rates (alpha>0) or ancestral states (1 or 2)
#         M8_cml.set_options(Small_Diff = .45e-6) # Default value.
#         M8_cml.set_options(cleandata = 0)	     # remove sites with ambiguity data (1:yes, 0:no)?
#         M8_cml.set_options(fix_blength = 0)	 # 0: ignore, -1: random, 1: initial, 2: fixed
#
#
#         M8_results=M8_cml.run(verbose=True)
#
# """
#         """
#         M8a_lnL=M8_results.get("NSsites").get(8).get("lnL")
#         M8a_paramList= M8_results.get("NSsites").get(8).get("parameters").get("parameter list").split()
#         M8a_np = len(M8a_paramList)
#         """
#
#
#             #
#             # try:
#             #     M8_cml.run(verbose=True)
#             # except:
#             #     ctlFile = output[0].split('/')[:-1][0] +'/'+output[0].split('/')[:-1][1]+'/'+"codeml.ctl"
#             #     M8_cml.ctl_file = ctlFile
#             #     M8_cml.write_ctl_file()
#             #     with open(output[0], "w") as out:
#             #         out.write("EMPTY alignment")
#     """    M01237_cml = codeml.Codeml()
#         M01237_cml.alignment = input.M01237_codonAlignment
#         M01237_cml.tree = input.M01237_tree
#         M01237_cml.out_file = output[1]
#         M01237_cml.working_dir = output[1].split('/')[:-1][0] +'/'+output[0].split('/')[:-1][1]+'/'+output[0].split('/')[:-1][2]+'/'
#
#
#         M01237_cml.set_options(noisy = 9)	         # 0,1,2,3,9: how much rubbish on the screen
#         M01237_cml.set_options(verbose = 1)	     # 1: detailed output, 0: concise output
#         M01237_cml.set_options(runmode = 0)	     # 0: user tree;  1: semi-automatic;  2: automatic
#         M01237_cml.set_options(seqtype = 1)	     # 1:codons; 2:AAs; 3:codons-->AAs
#         M01237_cml.set_options(CodonFreq = 2)	     # 0:1/61 each, 1:F1X4, 2:F3X4, 3:codon table
#         M01237_cml.set_options(clock = 0)	         # 0: no clock, unrooted tree, 1: clock, rooted tree
#         M01237_cml.set_options(aaDist = 0)	         # 0:equal, +:geometric; -:linear, {1-5:G1974,Miyata,c,p,v}
#         M01237_cml.set_options(model = 0)	         # models for codons:
#         M01237_cml.set_options(NSsites = [0,1,2,3,7,8])	     # 0:one w; 1:NearlyNeutral; 2:PositiveSelection; 3:discrete; Needs to be array
#         M01237_cml.set_options(icode = 0)	         # 0:standard genetic code; 1:mammalian mt; 2-10:see below
#         M01237_cml.set_options(Mgene = 0)	         # 0:rates, 1:separate; 2:pi, 3:kappa, 4:all
#         M01237_cml.set_options(fix_kappa = 0)	     # 1: kappa fixed, 0: kappa to be estimated
#         M01237_cml.set_options(kappa = 2)	         # initial or fixed kappa
#         M01237_cml.set_options(fix_omega = 0)	     # 1: omega or omega_1 fixed, 0: estimate
#         M01237_cml.set_options(omega = 1)	         # initial or fixed omega, for codons or codon-based AAs
#         M01237_cml.set_options(getSE = 0)	         # 0: don't want them, 1: want S.E.s of estimates
#         M01237_cml.set_options(RateAncestor = 0)	 # (0,1,2): rates (alpha>0) or ancestral states (1 or 2)
#         M01237_cml.set_options(Small_Diff = .45e-6) # Default value.
#         M01237_cml.set_options(cleandata = 0)	     # remove sites with ambiguity data (1:yes, 0:no)?
#         M01237_cml.set_options(fix_blength = 0)	 # 0: ignore, -1: random, 1: initial, 2: fixed
#
#
#         M01237_results = M01237_cml.run(verbose=True)
#
#
#
# """
# ##########################################
#         """
#         M0_lnL = M01237_results.get("NSsites").get(0).get("lnL")
#         M0_np = len(M01237_results.get("NSsites").get(0).get("parameters").get("parameter list").split())
#
#         M1a_lnL = M01237_results.get("NSsites").get(1).get("lnL")
#         M1a_np = len(M01237_results.get("NSsites").get(1).get("parameters").get("parameter list").split())
#
#         M2a_lnL = M01237_results.get("NSsites").get(2).get("lnL")
#         M2a_np = len(M01237_results.get("NSsites").get(2).get("parameters").get("parameter list").split())
#
#         M3_lnL = M01237_results.get("NSsites").get(3).get("lnL")
#         M3_np = len(M01237_results.get("NSsites").get(3).get("parameters").get("parameter list").split())
#
#         M7_lnL = M01237_results.get("NSsites").get(7).get("lnL")
#         M7_np = len(M01237_results.get("NSsites").get(7).get("parameters").get("parameter list").split())
#
#         M8_lnL = M01237_results.get("NSsites").get(8).get("lnL")
#         M8_np = len(M01237_results.get("NSsites").get(8).get("parameters").get("parameter list").split())
#
#         ####test M3-M0
#         summaryFile = "selection_results.txt"
#         with open(summaryFile, "a") as out:
#             out.write("famliy\tM3-M0\tM2a-M1a\tM8-M7\tM8-M8a\n")
#             lineToWrite = output[0].split('/')[-1].split('.')[0]
#             M3_M0 = 2*(M3_lnL-M0_lnL)
#             df_M3_M0 = M3_np - M0_np
#             #print(M3_M0)
#             if M3_M0 >=0:
#                 #print("P",cdf_chi2(df_M3_M0,M3_M0))
#                 lineToWrite+= str(cdf_chi2(df_M3_M0,M3_M0)) +"\t"
#             else:
#                 lineToWrite+="NA\t"
#
#
#             ##test M2a-M1a
#
#             M2a_M1a = 2*(M2a_lnL-M1a_lnL)
#             df_M2a_M1a = M2a_np - M1a_np
#
#             #print(M2a_M1a)
#             if M2a_M1a >=0:
#                 #print("P",cdf_chi2(df_M2a_M1a,M2a_M1a))
#                 lineToWrite+=str(cdf_chi2(df_M2a_M1a,M2a_M1a)) + "\t"
#             else:
#                 lineToWrite+="NA\t"
#
#             ## test M8-M7
#
#             M8_M7 = 2*(M8_lnL-M7_lnL)
#             df_M8_M7 = M8_np - M7_np
#             print(M8_M7)
#             if M8_M7 >= 0:
#                 #print("P",cdf_chi2(df_M8_M7,M8_M7))
#                 lineToWrite+=str(cdf_chi2(df_M8_M7,M8_M7)) +"\t"
#             else:
#                 lineToWrite+="NA\t"
#
#             #test M8 - M8a
#
#             M8_M8a = 2*(M8_lnL-M8a_lnL)
#             df_M8_M8a = M8_np - M8a_np
#             print(M8_M8a)
#             if M8_M8a >=0:
#                 #print("P",cdf_chi2(df_M8_M8a,M8_M8a))
#                 lineToWrite+= str(cdf_chi2(df_M8_M8a,M8_M8a)) +"\t"
#             else:
#                 lineToWrite+="NA\t"
#
#             out.write(lineToWrite+'\n')
#
#             """
#
#
#
#         # try:
#         #     M01237_cml.run(verbose=True)
#         # except:
#         #     ctlFile = output[0].split('/')[:-1][0] +'/'+output[0].split('/')[:-1][1]+'/'+output.split('/')[:-1][2]+'/'+"codemlM01237.ctl"
#         #     M01237_cml.ctl_file = ctlFile
#         #     M01237_cml.write_ctl_file()
#         #     with open(output[0], "w") as out:
#         #         out.write("EMPTY alignment")
#
# ########A sketch for how to get needed data from end of rst file
# """
# linesToPrint =""
# keepGoing=False
# BEB_found= False
# DATA_found = False
# with open("BEB.txt") as f:
#     for line in f:
#         # if keepGoing:
#         #     linesToPrint+=line
#         if "BEB" in line and "11" in line :
#             # linesToPrint+=line
#             BEB_found = True
#         if BEB_found:
#             if DATA_found == False:
#                 try:
#                     if line.split()[1] in "ACDEFGHIKLMNPQRSTVWY":
#                         linesToPrint+=line
#                         DATA_found = True
#                 except:
#                     0
#             else:
#                 try:
#                     if line.split()[1] in "ACDEFGHIKLMNPQRSTVWY":
#                         linesToPrint +=line
#                 except:
#                     print linesToPrint
#                     break
#
#
# """
