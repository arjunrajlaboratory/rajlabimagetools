"""
Checks generated SNP probes against RNA FISH probes. For each gene,
load a fasta file, RNA FISH probe list file, and SNP FISH probe list 
file. Then, back-calculate RNA FISH probe positions in gene, SNP FISH
probe positions in gene, and check for overlap. Reports any overlap.

Requires:
	- genes_SNPs.tsv SNP FISH probe file (in script)

	- .fasta files for all genes (in working directory)
	- gene_oligos.txt for all genes (in working directory)
"""

#Importing from general python Library
import csv
import os

#Importing for SNP-FISH Specific Design Library
import design
import seq
import fasta

#Set input file
snp_probe_list = 'SNPDesignForIan.tsv'

#Set output file
outfile = 'SNP_RNA_overlap.txt'

#Process SNP probes
f = open(snp_probe_list, 'r')
gene_reader = csv.reader(f, delimiter='\t')

genes_n_snpprobes = []  # [ (str)fasta_filename  (str)snp_probe ]
gene_reader.next()
for line in gene_reader:
	temp = line[0]
	gene = temp.split('-', 1)
	probe = line[1]
    genes_n_snpprobes.append( [ gene + '.fasta', probe ] )
del gene_reader

f.close()

#Loop through each SNP probe and check for overlapping RNA FISH probes
fastafilename = ''
for (id,set) in enumerate(genes_n_snps):

	if fastafilename is not set[0]:
        f = fasta.Fasta(set[0])  # load the Fasta
        fastafilename = f.filename







