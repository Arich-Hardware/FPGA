const int ctd=35, window=25, unit=4;
const int shift_ts=4, shift_tsf=2, shift_te=1, shift_tef=2;
const int trig_shift=40, pulse_shift=216;
const double circ_time=1e-5;
//Now trigger window is [T-(window+shift_ts)*unit, T-shift_ts*unit]=[T-118, T-18].
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

void format(){
	ifstream fi("testbench.dat");
	const int nchan=4;

	vector<double> stime, etime, ttime, stime_t, etime_t;
	vector<int> chan, chan_t;
	double st, et;
	int ichan;
	char flag;

	int t_now, t_s, t_sf;
	int s_now, s_s, s_sf, s_e, s_ef, trign=0;
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
			ttime.push_back(st-circ_time);
			stime_t.clear();
			etime_t.clear();
			chan_t.clear();
			for(int i=stime.size()-1;i>=0;i--){
				if(stime[i]>ttime.back()-window*unit-shift_ts*unit-shift_tsf){
					if(stime[i]>ttime.back()-shift_ts*unit-shift_tsf)continue;
					stime_t.push_back(stime[i]-circ_time);
					etime_t.push_back(etime[i]);
					chan_t.push_back(chan[i]);
				}
				else break;
			}

			if(stime_t.size()!=0){
				t_now=int(ttime.back()/unit)*unit+trig_shift;
				t_s=int(ttime.back()/unit);
				t_sf=phase(ttime.back());
				of<<Form("T %i %i %i %i", t_now, t_s, t_sf, trign)<<endl;
				for(int j=stime_t.size()-1;j>=0;j--){
					s_now=int(stime_t[j]/unit)*unit+pulse_shift;
					s_s=ctd+int(stime_t[j]/unit+0.5)-int(ttime.back()/unit);
					s_sf=phase(stime_t[j]);
					s_e=ctd+int(stime_t[j]/unit+0.5)-int((stime_t[j]+etime_t[j])/unit+0.5);
					s_ef=phase(stime_t[j]+etime_t[j]);
					CarryBorrow(&s_s, &s_sf, shift_ts, shift_tsf);
					CarryBorrow(&s_e, &s_ef, shift_te, shift_tef);
					if(s_s>=35)continue;
					of<<Form("S %i %i %i %i %i %i %-2i", s_now, chan_t[j], s_s, s_sf, s_e, s_ef, trign)<<endl;
				}
				trign++;
			}
		}
	}
}
