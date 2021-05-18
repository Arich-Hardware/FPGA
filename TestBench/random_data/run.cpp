#include <iostream>
#include <fstream>
#include "all.h"

using namespace std;

int main(int argc, char *argv[]){
	if(argc==1||argc>3){
		cout<<"./test_model testbench.dat nchan"<<endl;
		return -1;
	}

	string file0=string(argv[1]);
	int nchan=atoi(argv[2]);
	string file1="result.dat";
	string file2="../tdc_output.txt";

	format(file0, file1, nchan);
	read(file1, file2);
}
