void write(){

	const int nchan=4;
	const double dead_pulse=50, dead_trig=200;

	double dark_rate=6.25e-3, trigger_rate=30e-6;//per ns
	double dark_width_up=95;//width=5+ran*up
	double sim_time=1e7, trig_delay=90, Che_var=1;//ns, [T-100, T]=[T0-10, T0+90]
	double meanh=60./5e3;//average Cherenkov hit number per channel

	//dark hit, end of dark hit, trigger
	vector<double> dtime[nchan], etime[nchan], ttime;
	vector<int> ichan;
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
	
	sort(ttime.begin(), ttime.end());
	//remove too close triggers
	for(int i=0;i<ttime.size();i++){
		if(ttime[i]<ttime[i-1]+dead_trig){
			ttime.erase(ttime.begin()+i);
			i--;
		}
	}

	//sort by time
	for(int j=0;j<nchan;j++){
		sort(dtime[j].begin(), dtime[j].end());
		//remove overlaps in dark hits
		etime[j].push_back(gRandom->Rndm()*dark_width_up+5);
		ichan.push_back(j);
		for(int i=1;i<dtime[j].size();i++){
			if(dtime[j][i]<dtime[j][i-1]+etime[j][i-1]+dead_pulse){
			//if(dtime[j][i]<dtime[j][i-1]+50 || dtime[j][i]<dtime[j][i-1]+etime[j][i-1]){
				dtime[j].erase(dtime[j].begin()+i);
				i--;
			}
			else{
				etime[j].push_back(gRandom->Rndm()*dark_width_up+5);
				ichan.push_back(j);
			}
		}
	}

	//combine
	for(int j=1;j<nchan;j++){
		dtime[0].insert(dtime[0].end(), dtime[j].begin(), dtime[j].end());
		etime[0].insert(etime[0].end(), etime[j].begin(), etime[j].end());
	}
	vector<int> idx(dtime[0].size());
   iota(idx.begin(), idx.end(), 0);
	sort(idx.begin(),idx.end(), [&](int i,int j){return dtime[0][i]<dtime[0][j];} );
	sort(dtime[0].begin(), dtime[0].end());

	//print out
	ofstream out_f("testbench.dat");
	int ati=0;
	ntsim=ttime.size();
	for(int i=0;i<dtime[0].size();i++){
		if(dtime[0][i]<100)continue;
		while(ttime[ati]<dtime[0][i]&&ati<ntsim){
			out_f<<Form("T %0.1f",ttime[ati])<<endl;
			ati++;
		}
		out_f<<Form("S %0.1f %i %0.1f",dtime[0][i],ichan[idx[i]],etime[0][idx[i]])<<endl;
	}
}
