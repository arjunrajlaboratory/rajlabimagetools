"""Performs all the bookkeeping to create probes for SNP_FISH
For each gene, there is one or more SNP targets. We load the FASTA file for each 
gene and extract the 20-30bp target region with the SNP position at 5bp from the 
3' end. We also include two flanking bases for overhang stabilization. Then we can
provide the target sequence to the SNP probe designer.

Requirements
- SNP List Text File
- Fasta file(s) for gene(s) that one is designing against. Must have same name as gene 
	in SNP in the SNP List text File

"""

#Importing from general python Library
import csv
import os

#Importing for SNP-FISH Specific Design Library
import design
import seq
import fasta


# Input Files

SNPLIST = 'test_SNPs.txt'
OUTFILENAME = 'SNPDesignForIan.tsv'

# SNPLIST TSV file with FASTA file, SNP bases for WT and MUT and SNP positions
#   [0]     	[1]  	 	[2]        [3]             [4]
#   gene name    WT SNP 	MUT SNP    SNP position    other notes

#If gene n

f = open(SNPLIST, 'r')
gene_reader = csv.reader(f, delimiter='\t')


genes_n_snps = []  # [ (str)filename  (int)snp_position  (str)WT Base (str)MUT Base]
gene_reader.next()
for line in gene_reader:
    genes_n_snps.append( [ line[0] + '.fasta', int(line[3]), line[1], line[2], line[3], line[4] ] ) #should be int(line[3])?
del gene_reader

f.close()


fout = open(OUTFILENAME,'w')
oligo_writer = csv.writer(fout,delimiter='\t')

# For each SNP target

fastafilename = ''
for (id,set) in enumerate(genes_n_snps): 

    if fastafilename is not set[0]:
        f = fasta.Fasta(set[0])  # load the Fasta
        fastafilename = f.filename

    p    = set[1]  # snp position 
    WT   = set[2]  # the nucleotide at SNP position in WT
    MUT = set[3]  # the nucleotide at SNP position in MUT
    
    print p
    print WT
    print MUT
    
    ref  = f.seq_in_range(p,p)  # nucleotide at SNP position in reference Fasta
    
    is_pos_strand = f.strand[0] == '+'
    
    print p

    if not is_pos_strand:
        ref = seq.reverseComplement(ref.lower())
        ref = ref.upper()

    if WT != ref:
        print 'Wildtype base: ' + WT + ' FASTA file base:' + ref
        raise Exception("### SNP BASE DID NOT MATCH REFERENCE SEQUENCE ###")

    target3p = p  # 4 bases + 1 base overhang
    target3p += 5 if is_pos_strand else -5

    target5p = p
    
    add5p = 14
    target5p -= add5p if is_pos_strand else -1*add5p
    
    tolerance = -29
    binding_energy = 9999999
    
    while binding_energy > tolerance:  # Gibbs energy goes down with total length

        target5p -= 1 if is_pos_strand else -1
        deldelG = 999999
        toe = 5

        # get the sequence
        onlyexons = True
        if is_pos_strand:
            target = f.seq_in_range(target5p,target3p,onlyexons)
        else:
            target = f.seq_in_range(target3p,target5p,onlyexons)

        # design a SNP probe
        while deldelG > -6:
            probe, mask, binding_energy, toehold_energy, deldelG = \
                    design.create_mask_probe(target,'',3,toe)
            toe += 1

    # STDOUT print the gene name, then a formatted output for paternal probe
    
    toe -= 1
    probename = f.filename[:-6] + '-WT' + '-' + set[5]
    print probename
    for cut in [0, 2, 4]:
        probe, mask, binding_energy, toehold_energy, deldelG = \
                design.create_mask_probe(target,'',3,toe+cut)
        oligo_writer.writerow([probename,probe,mask,probename + '-t' + str(toe+cut)])
        design.print_mask_design(target, probe, mask, binding_energy, \
            toehold_energy, deldelG)

    probename = f.filename[:-6] + '-MUT' + '-' + set[5]
    print probename
    if not is_pos_strand:
        MUT = seq.reverseComplement(MUT.lower()).upper()
    target = target[:-6] + MUT + target[-5:]
    for cut in [0, 2, 4]:
        probe, mask, binding_energy, toehold_energy, deldelG = \
                design.create_mask_probe(target,'',3,toe+cut)
        oligo_writer.writerow([probename,probe,mask,probename + '-t' + str(toe+cut)])
        design.print_mask_design(target, probe, mask, binding_energy, \
            toehold_energy, deldelG)

fout.close()
