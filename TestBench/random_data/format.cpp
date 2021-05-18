#include <iostream>
#include <fstream>
#include <stdio.h>
#include <vector>

using namespace std;

const int ctd=35, window=25, tolerance=10, unit=4;
const int shift_ts=-2, shift_tsf=2, shift_ss=4, shift_ssf=2, shift_se=1, shift_sef=2;
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
		x[0]++;
	}
}
void AddMinus(int *x, int *y, int dx, int dy){
	x[0]=x[0]+dx;
	y[0]=y[0]+dy;
	if(y[0]>=unit){
		y[0]-=unit;
	}
}

void format(string file0, string file1, int nchan){
	ifstream fi(file0);

	vector<double> stime, etime, ttime, stime_t, etime_t;
	vector<int> chan, chan_t;
	double st, et;
	int ichan;
	char flag;

	int t_now, t_s, t_sf;
	int s_now, s_s, s_sf, s_e, s_ef, trign=0;
//	ofstream of(file1);
	FILE *of=fopen(file1.c_str(), "w");
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
				if(stime[i]>ttime.back()-ctd*unit){
					if(stime[i]>ttime.back())continue;
					//if(stime[i]>ttime.back()-shift_ts*unit-shift_tsf)continue;
					stime_t.push_back(stime[i]-circ_time);
					etime_t.push_back(etime[i]);
					chan_t.push_back(chan[i]);
				}
				else break;
			}

			t_now=int(ttime.back()/unit)*unit+trig_shift;
			t_s=int(ttime.back()/unit);
			t_sf=phase(ttime.back());
			CarryBorrow(&t_s, &t_sf, shift_ts, shift_tsf);
			fprintf(of, "T %i %i %i %i \n", t_now, t_s, t_sf, trign);

			if(stime_t.size()!=0){
				for(int j=stime_t.size()-1;j>=0;j--){
					s_now=int(stime_t[j]/unit)*unit+pulse_shift;
					s_s=ctd+int(stime_t[j]/unit+0.5)-int(ttime.back()/unit);
					s_sf=phase(stime_t[j]);
					s_e=ctd+int(stime_t[j]/unit+0.5)-int((stime_t[j]+etime_t[j])/unit+0.5);
					s_ef=phase(stime_t[j]+etime_t[j]);
					AddMinus(&s_s, &s_sf, shift_ss, shift_ssf);
					AddMinus(&s_e, &s_ef, shift_se, shift_sef);
					if(s_s>=35)continue;
					if(s_s<10)continue;
					if(chan_t[j]>=nchan)continue;
					fprintf(of, "S %i %i %i %i %i %i %-2i \n", s_now, chan_t[j], s_s, s_sf, s_e, s_ef, trign);
				}
			}
			trign++;
		}
	}
	fi.close();
	fclose(of);
}
