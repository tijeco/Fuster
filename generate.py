#!/usr/bin/env python
import generate
import sys
import json

def getOptionValue(option):
    optionPos = [i for i, j in enumerate(sys.argv) if j == option][0]
    optionValue = sys.argv[optionPos + 1]
    return optionValue



configDict = {}

if "-d" in sys.argv:
    input_directory = getOptionValue("-d")
else:
    input_directory = "data/"
    # print "\nplease specify input directory name using -d <file_name> \n"
    # sys.exit()

if "-t" in sys.argv:
    try:
        threads = int(getOptionValue("-t"))
    except:
        print("please enter an integer number using -t <number_of_threads> ")
        sys.exit()
else:
    threads=1



if "-orf" in sys.argv:
    orf_option = getOptionValue("-orf")
    print("Sorry, that option is not currently supported for this subroutine\nexiting")
    sys.exit()
else:
    orf_option="transdecoder"
    configDict["orf"]={"conda":"envs/transdecoder.yaml",
        "shell":"""
        TransDecoder.LongOrfs -t {input}  -m 30
        TransDecoder.Predict -t {input} --single_best_orf
        """
    }

if "-blast" in sys.argv:
    blast_option = getOptionValue("-blast")
    print("Sorry, that option is not currently supported for this subroutine\nexiting")
    sys.exit()
else:
    blast_option="diamond"
    configDict["blast"] = {"conda":"envs/diamond.yaml",
        "shell":"""
        diamond makedb --in {input} --out {input}.seq.db -d {input}
        diamond blastp -d {input} -d {input}.dmnd -q {input} -o {output} -p {threads} -e 1E-5
        """
    }

if "-clust" in sys.argv:
    clust_option = getOptionValue("-clust")
    print("Sorry, that option is not currently supported for this subroutine\nexiting")
    sys.exit()
else:
    clust_option="silix"
    configDict["clust"]={"shell":"silix -r 0.9 {input.sequence_file} {input.blast_file} > {output} || true"}

if "-align" in sys.argv:
    align_option = getOptionValue("-align")
    print("Sorry, that option is not currently supported for this subroutine\nexiting")
    sys.exit()
else:
    align_option="mafft"
    configDict["align"] = {"conda":"envs/mafft.yaml",
        "shell":"mafft --auto --thread -1 {input} > {output}"
    }

if "-tree" in sys.argv:
    tree_option = getOptionValue("-tree")
    print("Sorry, that option is not currently supported for this subroutine\nexiting")
    sys.exit()
else:
    tree_option="fasttree"
    configDict["tree"]={"conda":"envs/fasttree.yaml",
        "shell":"fasttree  -nosupport {input} > {output} || true"
    }
if "-model" in sys.argv:
    model_option = getOptionValue("-model")
    print("Sorry, that option is not currently supported for this subroutine\nexiting")
    sys.exit()
else:
    model_option="hyphy"
    #NOTE
    #TODO
    #FIXME
    configDict["model"]={"shell":"(echo 1; echo 1;echo " +'srcdir("{input.align}")'+"; echo "+ 'srcdir("{input.tree}")'+"; echo 20;echo 5; echo 2000000; echo 1000000;echo 100;echo 0.5 )|HYPHYMP /home/usr/hyphy/res/TemplateBatchFiles/FUBAR.bf"}






with open('configure.json', 'w') as fp:
    json.dump(configDict, fp)

with open("template/Snakefile") as f:
    print(f)

print("snakemake --snakefile " + "template/Snakefile -d "+input_directory+" --cores "+str(threads)+" --use-conda --configfile configure.json")




# print(configDict)
