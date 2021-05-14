void read(){

	ifstream f_soft("result.dat"), f_tdc("../tdc_output.txt");

	int err_ct=0;

	char tmpc, flag_soft, flag_tdc;
	int tmp, ts, tsf, trign;
	vector<int> ss, se, ssf, sef, chan;

	int i_trign, i_s, i_sf, i_e, i_ef, i_chan, npulse;
	f_soft>>flag_soft;
	f_tdc>>flag_tdc;
	while(f_soft.peek()!=EOF&&f_tdc.peek()!=EOF){
		if(flag_soft=='T'){
			f_soft>>tmp>>ts>>tsf>>trign;
			f_tdc>>tmp>>i_s>>i_sf>>i_trign;
			if(flag_tdc!='T'||trign!=i_trign||ts!=i_s||tsf!=i_sf){
				cout<<"Mismatch! Trigger #"<<trign<<endl;
				err_ct++;
			}
			ss.clear();
			se.clear();
			ssf.clear();
			sef.clear();
			chan.clear();
			npulse=0;
		
			f_soft>>flag_soft;
			while(flag_soft=='S'){
				flag_soft=' ';
				f_soft>>tmp>>i_chan>>i_s>>i_sf>>i_e>>i_ef>>tmp;
				ss.push_back(i_s);
				ssf.push_back(i_sf);
				se.push_back(i_e);
				sef.push_back(i_ef);
				chan.push_back(i_chan);
				f_soft>>flag_soft;
			}
			f_tdc>>flag_tdc;
			while(flag_tdc=='S'){
				flag_tdc=' ';
				f_tdc>>tmp>>i_chan>>i_s>>i_sf>>i_e>>i_ef>>tmp>>tmp>>tmpc>>tmpc;
				npulse++;
				int i=0;
				for(i=0;i<ss.size();i++){
					if(i_chan==chan[i]&&i_s==ss[i]&&i_sf==ssf[i]&&i_e==se[i]&&i_ef==sef[i])break;
				}
				if(i==ss.size()){
					cout<<"Mismatch! Trigger #"<<trign<<endl;
					err_ct++;
				}
				f_tdc>>flag_tdc;
			}
			if(npulse!=ss.size()){
				cout<<"Mismatch! Trigger #"<<trign<<endl;
				err_ct++;
			}
		}
	}
	if(err_ct==0)cout<<"Great! All matched!"<<endl;
}
