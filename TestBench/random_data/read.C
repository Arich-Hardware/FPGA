const int ctd=35, window=25, unit=4, trig_shift=166;
const int shift_ts=4, shift_tsf=0, shift_te=1, shift_tef=0;
//Now trigger window is [T-(window+shift_ts]*unit, T-shift_ts*unit]=[T-120, T-20].
//Trigger ~ signal + 30 ns + artificial delay (~80 ns)

int phase(double x){
	return int((x-int(x/unit)*unit));
}

void read(){
	ifstream fi("testbench.dat");
	const int nchan=4;

	vector<double> stime, etime, ttime, now;
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
			now.clear();
			ts.clear();
			te.clear();
			tsf.clear();
			tef.clear();
			tchan.clear();
			for(int i=stime.size()-1;i>=0;i--){
				if(stime[i]>ttime.back()-window*unit-(shift_ts+1)*unit){
					if(stime[i]>ttime.back()-(shift_ts+1)*unit)continue;
					now.push_back(int(stime[i])/unit*unit+trig_shift);
					ts.push_back(ctd+int((stime[i]-ttime.back())/unit));
					te.push_back(ctd+int(stime[i]/unit)-int((stime[i]+etime[i])/unit));
					tsf.push_back(phase(stime[i]));
					tef.push_back(phase(stime[i]+etime[i]));
					tchan.push_back(chan[i]);
				}
				else break;
			}
			for(int j=ts.size()-1;j>=0;j--){
				ts[j]+=shift_ts;
				tsf[j]+=shift_tsf;
				te[j]+=shift_te;
				tef[j]+=shift_tef;
				if(tsf[j]>unit){
					ts[j]++;
					tsf[j]-=unit;
				}
				if(tsf[j]<0){
					ts[j]--;
					tsf[j]+=unit;
				}
				if(tef[j]>unit){
					te[j]++;
					tef[j]-=unit;
				}
				if(tef[j]<0){
					te[j]--;
					tef[j]+=unit;
				}
				if(te[j]<0){
					te[j]=0;
					tef[j]=0;
				}
				if(tchan[j]==0)of<<Form("%i %2i %1i %2i %1i  %i", int(now[j]), ts[j], tsf[j], te[j], tef[j], int(ttime.size()))<<endl;
			}
		}
	}
}
