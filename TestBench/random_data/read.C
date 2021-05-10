const int ctd=35, window=25, unit=4;
const int shift_ts=4, shift_tsf=2, shift_te=1, shift_tef=2, trig_shift=164;
const double circ_time=1e-5;
//Now trigger window is [T-(window+shift_ts]*unit, T-shift_ts*unit]=[T-120, T-20].
//Trigger ~ signal + 30 ns + artificial delay (~80 ns)

int phase(double x){
	return int((x-int(x/unit)*unit));
}
void CarryBorrow(int *x, int *y, int dx, int dy){
	x[0]=x[0]+dx;
	y[0]=y[0]+dy;
	if(y[0]>=unit){
		y[0]-=unit;
	}
}

void read(){
	ifstream fi("testbench.dat");
	const int nchan=4;

	vector<double> stime, etime, ttime, now, read_stime;
	vector<int> chan;
	double st, et, read_time=0;
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
				if(stime[i]>ttime.back()-window*unit-(shift_ts)*unit){
//				if(stime[i]>ttime.back()-window*unit-(shift_ts)*unit&&stime[i]>read_time){
					if(stime[i]>ttime.back()-(shift_ts)*unit)continue;
					read_stime.push_back(stime[i]);
					now.push_back(int(stime[i]/unit+0.5-circ_time)*unit+trig_shift);
					ts.push_back(ctd+int(stime[i]/unit+0.5-circ_time)-int(ttime.back()/unit));
					te.push_back(ctd+int(stime[i]/unit+0.5-circ_time)-int((stime[i]+etime[i])/unit+0.5-circ_time));
					tsf.push_back(phase(stime[i]-circ_time));
					tef.push_back(phase(stime[i]+etime[i]-circ_time));
					tchan.push_back(chan[i]);
				}
				else break;
			}
			for(int j=ts.size()-1;j>=0;j--){
				CarryBorrow(&ts[j], &tsf[j], shift_ts, shift_tsf);
				CarryBorrow(&te[j], &tef[j], shift_te, shift_tef);
				if(tchan[j]==0){
					of<<Form("%i %2i %1i %2i %1i  %-2i", int(now[j]), ts[j], tsf[j], te[j], tef[j], int(ttime.size()))<<endl;
					read_time=read_stime[j];
				}
			}
		}
	}
}
