library(tidyr)
library(dplyr)
library(RColorBrewer)
library(knitr)
library(ggplot2)

setwd("C:/Users/jcheu/Documents/School/2019 Winter sem/1st sem/MICB 405/project-2")
arc_class <- read.table("gtdbtk.ar122.classification_pplacer.tsv", sep="\t")
bac_class <- read.table("gtdbtk.bac120.classification_pplacer.tsv", sep="\t")
gtdb_dat <- rbind(arc_class, bac_class) %>% 
  dplyr::rename(mag = V1) %>% 
  separate(V2, sep=';', into=c("Kingdom", "Phylum", "Class", "Order", "Family", "Genus", "Species")) %>%
  dplyr::select(mag, Kingdom, Phylum, Class, Order, Family)
checkm_dat <- read.table("MetaBAT2_SaanichInlet_135m_min1500_checkM_stdout.tsv",
                         header=TRUE,
                         sep="\t",
                         comment.char = '') %>% 
  dplyr::rename(mag = Bin.Id) %>% 
  dplyr::select(mag, Completeness, Contamination)

metat_rpkm <- read.table("high-concat_ORFs_RPKM.csv", sep=',') %>% 
  dplyr::rename(orf = V1) %>% 
  dplyr::rename(rpkm = V2)

# Due to a bug in the renaming script we have to rename the bins. Its a bit hacky but works using tidyverse functions
metat_rpkm <- read.table("high-concat_ORFs_RPKM.csv", header=T, sep=',') %>% 
  mutate(Sequence = gsub('m_', 'm.', Sequence)) %>% 
  mutate(Sequence = gsub('Inlet_', 'Inlet.', Sequence)) %>% 
  separate(col=Sequence, into=c("mag", "contig"), sep='_', extra="merge") %>% 
  group_by(Sample, mag) %>% 
  summarise(g_rpkm = sum(RPKM)) %>% 
  mutate(mag = gsub('Inlet.', 'Inlet_', mag))

rpkm_dat <- left_join(metat_rpkm, checkm_dat, by="mag") %>% 
left_join(gtdb_dat, by="mag")
filter(Completeness> 90 & Contamination< 5)%>%
 group_by(mag, Kingdom, Phylum, Class, Completeness, Contamination) %>% 
summarise(metaT_rpkm = mean(metaT_rpkm))
ggplot(rpkm_dat, aes(x=Completeness, y=Contamination, col=Class)) +
geom_point(aes(size=metaT_rpkm)) +
scale_size(range=c(1,10)) +
xlim(c(90,100)) +
ylim(c(0,5)) +
theme(panel.background = element_blank(),
panel.grid.major = element_line(colour = "#bdbdbd", linetype = "dotted"),
panel.grid.minor = element_blank())
p <- ggplot(rpkm_dat, aes(x=Completeness, y=Contamination, col=Class)) + geom_point(aes(size=metaT_rpkm)) + ylim(c(0,30)) + scale_size(range=c(1,10)) + xlim(c(0,100)) + xlab("Completeness(%)") + ylab("Contamination(%)") + theme_minimal()
p
p+ geom_vline(xintercept = 90, na.rm=FALSE, show.legend = NA, linetype = "dashed", colour = "#311E90") + 
geom_vline(xintercept = 70, na.rm=FALSE, show.legend = NA, linetype = "dashed", colour = "#311E90") + 
geom_vline(xintercept = 50, na.rm=FALSE, show.legend = NA, linetype = "dashed", colour = "#311E90") +
geom_hline(yintercept = 15, na.rm=FALSE, show.legend = NA, linetype = "dashed", colour = "#311E90") +
geom_hline(yintercept = 10, na.rm=FALSE, show.legend = NA, linetype = "dashed", colour = "#311E90") +
geom_hline(yintercept = 5, na.rm=FALSE, show.legend = NA, linetype = "dashed", colour = "#311E90") 
rpkm_dat <- left_join(metat_rpkm, checkm_dat, by="mag")
high_qual_dat <- subset(rpkm_dat, Completeness > 90 & Contamination < 5)
mag_filenames <- high_qual_dat[,1]

       
       
