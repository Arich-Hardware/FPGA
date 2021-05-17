#include <iostream>
#include <fstream>
#include "all.h"

using namespace std;

int main(int argc, char *argv[]){
	if(argc==1||argc>2){
		cout<<"./test_model testbench.dat"<<endl;
		return -1;
	}

	string file0=string(argv[1]);
	string file1="result.dat";
	string file2="../tdc_output.txt";

	format(file0, file1);
	read(file1, file2);
}
