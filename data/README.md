# Data set generation procedure
All datasets are produced from publicly available resources, and are available for research purposes upon reasonable request.

## Internal validation dataset
We include putative non-AMR genes from the RefSeq database. Using BLAST, we select the top 1,000 RefSeq bacterial genes that do not match to MEGARes (e-value=10), aiming for a 1:1 target ratio with the antibiotic class of highest frequency.
To mimic genes that likely do not provide AMR but share a significant similarity with AMR genes we inlcude AMR-homologous genes and gene fragments from the human genome (GRCh38), and all the contigs in RefSeq labelled as 'vertebrate mammalian' and 'vertebrate other' assemblies. To do so, we run an ungapped BLAST search of all MEGARes genes against these human and vertebrate sequences (e-value=0.01). We use each unique sequence match, and add the flanking region to each match, elongating the matched sequence to be equal in length to the corresponding resistant MEGARes gene.

* Resistant sequences for the considered AMR classes are contained in MEGARes 2.0. Please note that sequences annotated with `RequiresSNPConfirmation` are excluded.
* Refseq susceptible sequences (putative non-AMR bacterial genes; human and vertrebrate genes) are listed in `susceptible_sequences_internal_validation.txt`

## PSS_molecule dataset
We rank the PATRIC drug labels based on number of associated genomes, and we select the top ones based on the associated MEGARes classes. We exclude labels with less than 250 genomes, or labels not referring to a specific molecule (e.g., Tetracycline). We generate 250,000 short reads for each PATRIC label, equally divided between resistant and susceptible. 

* PATRIC genomes utilized to build the PSS\_molecule set are listed in `PSS_molecule_genome_files.tar.xz`

## PSS_class dataset
Sequences used for PSS\_class come form PATRIC genomes. First we remove genomes presenting inconsistent class annotations, i.e., that are annotated as both resistant and susceptible to antibiotics belonging to the same class. Second, in order to consider only genomes that are resistant (or susceptible) to the range of antibiotics within a given MEGARes class, we rank each genome in decreasing order of the total number of annotations of resistance (or susceptibility) to multiple drugs within the same class. Based on this ranking, we retain only genomes that rank over the 90th percentile. Third, we perform a class-by-class BLAST filtering (e-value=0.01, percent identity between 70 and 90) of the selected PATRIC genomes against MEGARes genes, retaining and clipping the unique genes of PATRIC genomes that match MEGARes.

* PATRIC genes utilized to build the PSS\_molecule set are listed in `PSS_class_gene_files.tar.xz`

# Metagenomics datasets
The two real-world datasets come from functional metagenomics experiments previously used as external benchmark for the Meta-MARC tool, referred as the 'Pediatric' and the 'Soil' datasets (NCBI BioProject Accessions PRJNA244044 and PRJNA215106). We randomly select 100,000 short read pairs for each class as for the PATRIC datasets.

* Selected short read pairs are listed in `metagenomics_short_reads.tar.xz`
