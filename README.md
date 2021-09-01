# AMR-meta

AMR-meta is a machine-learning method to predict class-specific antimicrobial resistance (AMR) in metagenomics short read pairs (FASTQ). AMR-meta is an ensemble of AMR class-specific models based on [MEGARes](https://megares.meglab.org/) classes. AMR-meta is developed in Linux, ad utilizes Bash, C++, and R.

## Considered AMR Classes
* Aminoglycosides
* Betalactams
* Drug and biocide resistance
* Fluoroquinolones
* Glycopeptides
* Lipopeptides
* MLS
* Multi-biocide resistance
* Multi-drug resistance
* Multi-metal resistance
* Phenicol
* Sulfonamides
* Tetracyclines

# Principles
AMR-meta is based on multiple binary models, one per AMR class. Each class has _two_ models
* one based on _k_-mers and LASSO logistic regression
* one based on metafeatures (obtained by _k_-mers matrix factorization) and ridge logistic regression

# Installation

## Makefile
To install AMR-meta, download this repository and run:
```
make
```
AMR-meta uses the following R packages: `Matrix`, `stringr`, `glmnet`. AMR-meta will check if these R packages are installed before running.

## Singularity
AMR-meta is available as Singularity container, downloadable from genome.ufl.edu.

# Usage
```
./AMR-meta.sh -a FASTQ_R1 -b FASTQ_R2 -o OUT_DIR -p NCORES
	-a	short read R1 file [fastq]
        -b	short read R2 file [fastq]
        -o	output directory, defaults to output
        -p	# of cores for parallel computing, defaults to 1
        
Singularity:
singularity run amrmeta.sif -a FASTQ_R1 -b FASTQ_R2 -o OUT_DIR -p NCORES

        examples of use:
        ./AMR-meta.sh -a data/example/example_R1.fastq \\
                -b data/example/example_R2.fastq \\
                -o output \\
                -p 4
                
        singularity run amrmeta.sif -a data/example/example_R1.fastq \\
                -b data/example/example_R2.fastq \\
                -o output \\
                -p 4
```

# Output
For each short read pair, AMR-meta will output a probability for each model of the read pair of being labeled as resistant. An example of output file is the following:

 | Aminoglycosides | betalactams | Drug and biocide resistance | Fluoroquinolones | Glycopeptides | Lipopeptides | MLS | Multi-biocide resistance | Multi-drug resistance | Multi-metal resistance | Phenicol | Sulfonamides | Tetracyclines | 
 |  ---  |  ---  |  ---  |  ---  |  ---  |  ---  |  ---  |  ---  |  ---  |  ---  |  ---  |  ---  | ---   |
 | 0.302 | 0.065 | 0.494 | 0.017 | 0.392 | 0.251 | 0.434 | 0.398 | 0.474 | 0.488 | 0.120 | 0.546 | 0.194 | 
 | 0.302 | 0.065 | 0.494 | 0.040 | 0.322 | 0.251 | 0.434 | 0.398 | 0.091 | 0.211 | 0.167 | 0.530 | 0.308 | 
 | 0.999 | 0.382 | 0.001 | 0.012 | 0.000 | 0.051 | 0.001 | 0.015 | 0.800 | 0.678 | 0.104 | 0.003 | 0.275 | 
 | 0.302 | 0.065 | 0.496 | 0.040 | 0.392 | 0.511 | 0.434 | 0.398 | 0.474 | 0.678 | 0.104 | 0.003 | 0.275 | 
 | 0.302 | 0.065 | 0.494 | 0.040 | 0.385 | 0.717 | 0.117 | 0.434 | 0.398 | 0.678 | 0.104 | 0.003 | 0.275 | 
 | 0.302 | 0.065 | 0.494 | 0.063 | 0.392 | 0.007 | 0.965 | 0.251 | 0.434 | 0.398 | 0.474 | 0.488 | 0.137 | 

Here, each line corresponds to a read pair in the input fastq files (same order).

# References:
* [Doster E, et al. "MEGARes 2.0: a database for classification of antimicrobial drug, biocide and metal resistance determinants in metagenomic sequence data." NAR 2019](https://academic.oup.com/nar/article/48/D1/D561/5624973)
* [Marini S., et al. "Protease target prediction via matrix factorization." Bioinformatics (2018).](https://doi.org/10.1093/bioinformatics/bty746)
* [Vitali F., et al. "Patient similarity by joint matrix trifactorization to identify subgroups in acute myeloid leukemia." JAMIA Open (2018).](https://doi.org/10.1093/jamiaopen/ooy008)

### MIT License

Copyright (c) [2021] [Simone Marini et al.]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
