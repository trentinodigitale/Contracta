function TESTATA_OnLoad(){

	objdata1=getObj('ScadenzaIstanza_V');
	objdata2=getObj('ScadenzaOfferta_V');
	
	if (objdata1 == null)
		if (getObj('ScadenzaOfferta').value != ''){
			parent.opener.SaveDoc();
			self.close();
		}
	else{
		if (getObj('ScadenzaIstanza').value != '' && getObj('ScadenzaOfferta').value !='') {
			parent.opener.SaveDoc();
			self.close();
		}
	}	
		
}