#load libraries needed
library(readr)
library(dplyr)
library(tidyr)
library(RColorBrewer)
library(knitr)
library(ggplot2)
library(KEGGREST)
library(stringr)
library(tibble)
BiocManager::install("pathview")
library(pathview)

ko <- read.table("concat-high-ko.cleaned.txt") %>% 
  dplyr::rename(orf = V1) %>% 
  dplyr::rename(ko = V2)
metat_rpkm <- read.table("high-concat_ORFs_RPKM.csv", sep=',') %>% 
  dplyr::rename(orf = V1) %>% 
  dplyr::rename(rpkm = V2)

#make the Prokka map first
prokka_mag_map <- read.table("Prokka_MAG_map (1).csv", header=F, sep=',') %>% 
  dplyr::rename(prokka_id = V1) %>% 
  dplyr::rename(mag = V2)

arc_class <- read.table("gtdbtk.ar122.classification_pplacer.tsv", sep="\t")
bac_class <- read.table("gtdbtk.bac120.classification_pplacer.tsv", sep="\t")
gtdb_dat <- rbind(arc_class, bac_class) %>% 
  dplyr::rename(mag = V1) %>% 
  separate(V2, sep=';', into=c("Kingdom", "Phylum", "Class", "Order", "Family", "Genus", "Species"))

checkm_dat <- read.table("MetaBAT2_SaanichInlet_135m_min1500_checkM_stdout.tsv",
                         header=TRUE,
                         sep="\t",
                         comment.char = '') %>% 
  dplyr::rename(mag = Bin.Id) %>% 
  dplyr::select(mag, Completeness, Contamination)

# Rename the bins. 
metag_rpkm <- read.table("SaanichInlet_135m_binned.rpkm.csv", header=T, sep=',') %>% 
  mutate(Sequence = gsub('m_', 'm.', Sequence)) %>% 
  mutate(Sequence = gsub('Inlet_', 'Inlet.', Sequence)) %>% 
  separate(col=Sequence, into=c("mag", "contig"), sep='_', extra="merge") %>% 
  group_by(Sample, mag) %>% 
  summarise(g_rpkm = sum(RPKM)) %>% 
  mutate(mag = gsub('Inlet.', 'Inlet_', mag))

#removes Genus and Species fields 
gtdb_dat %>% 
  group_by(Phylum) %>% 
  summarise(count = n_distinct(mag)) %>% 
  kable()

gtdb_dat <- dplyr::select(gtdb_dat, mag, Kingdom, Phylum, Class, Order, Family)

rpkm_dat <- left_join(ko, metat_rpkm, by="orf") %>%
  separate(orf, into=c("prokka_id", "orf_id")) %>% # Split the Prokka ORF names into MAG identifier and ORF number for joining
  left_join(prokka_mag_map, by="prokka_id") %>% 
  left_join(gtdb_dat, by="mag") %>% 
  left_join(checkm_dat, by="mag")

# Download named vector of reference pathways and enzymes
enzyme_lookup<-keggLink ('enzyme','ko')
enzyme <- keggList('enzyme')
pathway_lookup <-keggLink('enzyme','pathway')

# Replace "path:map" in the names of vector with "K" so format is K#####
names(enzyme_lookup) <- str_replace(names(enzyme_lookup), "ko:K", "K")

# Convert lookup vector into table
enzyme_lookup<- enframe(enzyme_lookup)
enzyme<-enframe(enzyme)
pathway_lookup<-enframe(pathway_lookup)

# Rename variable names (use the same name for the ko variable as you have it in your current table, usually ko)
names(enzyme)<-c("enzyme_num", "enzyme")
names(enzyme_lookup) <- c("ko", "enzyme_num")
names(pathway_lookup) <- c("pathway", "enzyme_num")

#change ko:K to K
enzyme_lookup<-mutate(enzyme_lookup,ko = gsub('ko:K', 'K',ko))

# Join the tables together via KO number
enzyme_table<-left_join(enzyme_lookup,enzyme)
enzyme_table<-left_join(enzyme_table, pathway_lookup)

#separate the enzyme column to have short enzyme name
enzyme_table<- separate(enzyme_table, enzyme, sep=';',into = c('enzyme','rest_name'),extra = 'merge')

#join with rpkm data
rpkm_dat <- left_join(rpkm_dat, enzyme_table)

#filter by specific pathway (pathway number found on KEGG)
pathway_dat<- filter(rpkm_dat,pathway=='path:map00910')

#plot the bubbleplot for each pathway
ggplot(pathway_dat, aes(x=enzyme, y=mag, col=Phylum)) +
  geom_point(aes(size=rpkm)) +
  theme(panel.background = element_blank(),
        panel.grid.major = element_line(colour = "#bdbdbd", linetype = "dotted"),
        panel.grid.minor = element_blank(),
        axis.title.y = element_text(angle = 0),
        axis.text.x = element_text(angle = 45,
                                   hjust = 1))
