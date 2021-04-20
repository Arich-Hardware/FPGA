void write(){

	double dark_rate=6.25e-3, trigger_rate=30e-6;//per ns
	double sim_time=1e6, trig_delay=100, Che_var=1;//ns
	double meanh=60./5e3;//average Cherenkov hit number per channel

	//dark hit, end of dark hit, trigger
	vector<double> dtime, etime, ttime;
	//number of hits
	int ndsim=gRandom->Poisson(dark_rate*sim_time);
	int ntsim=gRandom->Poisson(trigger_rate*sim_time);
	//generate dark hits
	for(int i=0;i<ndsim;i++){
		dtime.push_back(gRandom->Rndm()*sim_time);
	}
	//generate triggers
	for(int i=0;i<ntsim;i++){
		ttime.push_back(gRandom->Rndm()*sim_time);
		//signal hits with triggers if any
		for(int j=0;j<gRandom->Gaus(meanh,sqrt(meanh));j++){
			dtime.push_back((gRandom->Rndm()-0.5)*Che_var+ttime[i]-trig_delay);
		}
	}
	//sort by time
	sort(dtime.begin(), dtime.end());
	sort(ttime.begin(), ttime.end());
	//remove overlaps in dark hits
	etime.push_back(gRandom->Rndm()*100);
	for(int i=1;i<dtime.size();i++){
		if(dtime[i]<dtime[i-1]+50 || dtime[i]<dtime[i-1]+etime[i-1]){
			dtime.erase(dtime.begin()+i);
			i--;
		}
		else etime.push_back(gRandom->Rndm()*100);
	}

	//print out
	int ati=0;
	for(int i=0;i<dtime.size();i++){
		if(ati<ntsim)if(ttime[ati]<dtime[i]){
			cout<<Form("T %0.1f",ttime[ati])<<endl;
			ati++;
		}
		cout<<Form("S %0.1f 0 %0.1f",dtime[i],etime[i])<<endl;
	}
}
