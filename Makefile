# makefile
all:
	g++ -o bin/prep_features bin/prep_features.cpp -std=c++11
	cat data/metaf.matrix.part-0* > data/metaf.matrix.rds
	rm data/metaf.matrix.part-0*
	


