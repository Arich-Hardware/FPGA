void write(){

	const int nchan=4;

	double dark_rate=6.25e-3, trigger_rate=30e-6;//per ns
	double sim_time=1e6, trig_delay=100, Che_var=1;//ns
	double meanh=60./5e3;//average Cherenkov hit number per channel

	//dark hit, end of dark hit, trigger
	vector<double> dtime[nchan], etime[nchan], ttime;
	//number of hits
	int ndsim;
	for(int j=0;j<nchan;j++){
		ndsim=gRandom->Poisson(dark_rate*sim_time);
		//generate dark hits
		for(int i=0;i<ndsim;i++){
			dtime[j].push_back(gRandom->Rndm()*sim_time);
		}
	}
	int ntsim=gRandom->Poisson(trigger_rate*sim_time);
	//generate triggers
	for(int i=0;i<ntsim;i++){
		ttime.push_back(gRandom->Rndm()*sim_time);
		//signal hits with triggers if any
		for(int j=0;j<gRandom->Gaus(meanh,sqrt(meanh));j++){
			dtime[int(gRandom->Rndm()*4)].push_back((gRandom->Rndm()-0.5)*Che_var+ttime[i]-trig_delay);
		}
	}

	//sort by time
	for(int j=0;j<nchan;j++){
		sort(dtime[j].begin(), dtime[j].end());
		//remove overlaps in dark hits
		etime[j].push_back(gRandom->Rndm()*100);
		for(int i=1;i<dtime[j].size();i++){
			if(dtime[j][i]<dtime[j][i-1]+50 || dtime[j][i]<dtime[j][i-1]+etime[j][i-1]){
				dtime[j].erase(dtime[j].begin()+i);
				i--;
			}
			else etime[j].push_back(gRandom->Rndm()*100);
		}
	}
	sort(ttime.begin(), ttime.end());

	//print out
	ofstream tri_f("trigger.dat");
	ofstream hit_f[4];
	for(int i=0;i<ttime.size();i++)tri_f<<Form("T %0.1f",ttime[i])<<endl;
	for(int j=0;j<nchan;j++){
		hit_f[j].open(Form("hit_%i.dat",j));
		for(int i=0;i<dtime[j].size();i++){
			hit_f[j]<<Form("S %0.1f %i %0.1f",dtime[j][i],j,etime[j][i])<<endl;
		}
	}
}
