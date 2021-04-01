#include <iostream>
#include <string>
#include <unordered_map>
#include <fstream> 
#include <vector>
#include <algorithm>

int main (int argc, char** argv)
{
  std::vector<std::string> ref_kmers;
  std::vector<std::string> ref_kmers_rc;
  std::string single_kmer;
  std::ifstream file_kmers(argv[4]);
  std::ifstream file_kmers_rc(argv[5]);
  
  while (std::getline(file_kmers, single_kmer)){
  ref_kmers.push_back(single_kmer);
    }
  
  while (std::getline(file_kmers_rc, single_kmer)){
    ref_kmers_rc.push_back(single_kmer);
    }
  
  std::unordered_map<std::string,uint> kmer_map;
  for (int i = 0; i < ref_kmers.size(); i++) {
    kmer_map[ref_kmers.at(i)] = i;
    kmer_map[ref_kmers_rc.at(i)] = i;
    }
  
  std::ifstream file_1(argv[1]);
  std::ifstream file_2(argv[2]);
  std::string str_1; 
  std::string str_2;
  std::string full_str; 
  const unsigned int k=13;
  const unsigned int l_ref=138260;
  unsigned int l=2; // fastq line counter
  const unsigned int max_pairs_per_file = 500000;
  unsigned int file_index=0;	// chop output into files with 100K short read pairs max
  
  while (std::getline(file_1, str_1)){
    std::getline(file_2, str_2);
    l++;
    if(l % 4 == 0){	// extract kmers every 4th fasqt line 
      std::transform(str_1.begin(), str_1.end(), str_1.begin(), ::toupper); 
      std::transform(str_2.begin(), str_2.end(), str_2.begin(), ::toupper); 
      
      bool kmer_arr[l_ref] = {false};
      for (int i = 0; i < (str_1.size()-k+1); i++){
        if (kmer_map.count(str_1.substr(i,k))>0){
          kmer_arr[kmer_map[str_1.substr(i,k)]]=true;
          }
        }
      
      for (int i = 0; i < (str_2.size()-k+1); i++){
        if (kmer_map.count(str_2.substr(i,k))>0){
          kmer_arr[kmer_map[str_2.substr(i,k)]]=true;
          }
        }
        
      std::string kmer_str;
      bool celo = false;  // flag indicating at least one known kmer is found
      for (int i = 0; i < l_ref; i++ ) {
        if(kmer_arr[i] == 1){
          kmer_str += std::to_string(i+1);
          kmer_str += ',';
          celo=true;
          }
        }

      if(celo==true){
        kmer_str.insert(0,std::to_string(l/4-(file_index*max_pairs_per_file))+=',');
        kmer_str += '\n';
        full_str += kmer_str;
        }
      } // l==4
    
    if(l % (4*max_pairs_per_file) == 0){
      std::ofstream outfile (std::string(argv[3]) + "_" + std::to_string(file_index) + ".csv");
      if (outfile.is_open()){    
        full_str += std::to_string(l/4-(file_index*max_pairs_per_file))+='\n';  // add total number of read pairs as the last line of the file
        outfile << full_str;
        outfile.close();      
        file_index++;
        full_str.clear();
        }
      } // writing chunk to file
    } // reading from file
    std::ofstream outfile (std::string(argv[3]) + "_" + std::to_string(file_index) + ".csv");
    if (outfile.is_open()){    
      full_str += std::to_string(l/4-(file_index*max_pairs_per_file))+='\n';  // add total number of read pairs as the last line of the file
      outfile << full_str;
      outfile.close(); 
      }
  return 0;
} // main
