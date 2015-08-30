setwd("/Users/ian/Dropbox/Tissue SNP FISH/")
snps<-read.table("SNPsINGenes_ForIan.txt",header=T)
newtab<-list()
newtab$GeneName<-snps$gene
newtab$WT<-snps$C57BL.6J
newtab$MUT<-snps$CAST.EiJ
newtab$SNPposition<-snps$bploc
newtab<-as.data.frame(newtab)
temp<-character()
for (i in 1:10){
  temp[i] = paste0("Actn4_SNP", as.character(i))
}
for (i in 1:10){
  temp[i+10] = paste0("Tbcb_SNP", as.character(i))
}
for (i in 1:4){
  temp[i+20] = paste0("Supt5_SNP", as.character(i))
}
newtab$SNP_ID<-temp
outfil<-"test_SNPs.txt"
write.table(newtab,file=outfil,quote=F,sep="\t",row.names=F)
