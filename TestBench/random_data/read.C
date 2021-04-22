int phase(double x){
	return int((x-int(x/4)*4));
}

const double ctd=35, window=25, unit=4;

void read(){
	ifstream fi("testbench.dat");
	const int nchan=4;

	vector<double> stime, etime, ttime;
	vector<int> chan;
	double st, et;
	int ichan;
	char flag;

	vector<int> ts, te, tsf, tef, tchan;
	ofstream of("result.dat");
	while(fi.peek()!=EOF){
		fi>>flag;
		if(flag=='S'){
			fi>>st>>ichan>>et;
			stime.push_back(st);
			chan.push_back(ichan);
			etime.push_back(et);
		}
		else if(flag=='T'){
			fi>>st;
			ttime.push_back(st);
			of<<Form("T %6i",int(st))<<endl;
			ts.clear();
			te.clear();
			tsf.clear();
			tef.clear();
			tchan.clear();
			for(int i=stime.size()-1;i>=0;i--){
				if(stime[i]>ttime.back()-window*unit){					
					ts.push_back(ctd+int(stime[i]/4)-int(ttime.back()/4));
					te.push_back(ctd+int(stime[i]/4)-int((stime[i]+etime[i])/4));
					tsf.push_back(phase(stime[i])-phase(ttime.back()));
					tef.push_back(phase(stime[i])-phase(stime[i]+etime[i]));
					tchan.push_back(chan[i]);
				}
				else break;
			}
			for(int j=ts.size()-1;j>=0;j--){
				if(tsf[j]<0){
					ts[j]--;
					tsf[j]+=4;
				}
				if(tef[j]<0){
					te[j]--;
					tef[j]+=4;
				}
				if(te[j]<0){
					te[j]=0;
					tef[j]=0;
				}
				of<<Form("%3i %1i %3i %1i %3i %i", ts[j], tsf[j], te[j], tef[j], int(ttime.size()), tchan[j])<<endl;
			}
		}
	}
}
