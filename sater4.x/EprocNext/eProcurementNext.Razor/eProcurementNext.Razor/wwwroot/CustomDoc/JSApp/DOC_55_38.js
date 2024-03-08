<script language="javascript">

//Controllo per ogni sezione da firmare se ci sono attributi editabili.
//Se non ci sono nascondo help per la firma ,comando di firma e attributo di firma 

//recupero le sezioni del documento
var infotab;
var ainfotab;
var bEditable;

bEditable=false;
infotab=getObj('INFOTAB').value;
ainfotab=infotab.split('#~');

//ciclo sulle sezioni per controllare se ci sono attributi editabili
for (i=0; i < ainfotab.length; i++){
	bEditable=false;
	ainfosection= ainfotab[i].split('~');
	
	//se  una sezione da firmare
	//if (ainfosection[0]=='PRODUCTS'  && getObj( ainfosection[1] + '_SIGNATURE').value == '0#1' ){

	if (ainfosection[1]=='DOCUMENTAZIONE' ){
		bEditable=true;
 	}else{
	if (ainfosection[0]=='PRODUCTS' ){
		
		ainfoaree=ainfosection[3].split('@');
		
		for (k=0; k < ainfoaree.length; k++){
			
			ainf=ainfoaree[k].split(';');
			strAreaName=ainf[1];
			
			switch (ainf[0]){
				
				case 'V':				
					//area comune	
					try{
							
						ListAttrib=getObj('ListAttrib_' + ainfosection[1] + '_' + strAreaName).value;
						if (ListAttrib != ''){
							ainfo=ListAttrib.split('#');
							nNumComune=ainfo.length;
							for (j=0; j < ainfo.length; j++){
								InfoAttrib=ainfo[j];
								ainfo1=ainfo[j].split(';');
								
								if (ainfo1[0] == 'FirmaBusta'){
									strAreaOFID=strAreaName;
									strIdDztFirma=ainfo1[1];
									//alert(strAreaOFID);
								}

								if ( ainfo1[6]=='1' && ainfo1[0] != 'FirmaBusta' ){
									bEditable=true
									//break;
								}
							}
						}
					}catch(e){
					}
					break;
				
				case 'G':
					//area griglia
					
					if (strAreaName=='griglia'){	
					try{
						ListDomini=getObj('DOMINI_' + ainfosection[1] + '_' + strAreaName).value; 
						if (ListDomini != ''){
							ainfo=ListDomini.split('#');
							for (j=0; j < ainfo.length; j++){
								InfoAttrib=ainfo[j];
								ainfo1=ainfo[j].split(';');
								npos=ainfo1[0].indexOf('-4#~');
								npos1=ainfo1[0].indexOf('-6#~');
								if (  ainfo1[0] == '0' || ainfo1[0] == '1' || ainfo1[0] == '-3' || ainfo1[0] == '-11' || ainfo1[0] > '0' || npos > 0 || npos1 > 0 ){
									bEditable=true
									break;
								}
							}
						}
					}catch(e){
					}			
					}	 
					break;
				
			}
			
			
			//if (bEditable)
			//	break;
			
		}
		
		//nascondo area e info della firma
		
		if (! bEditable || getObj('Cover1_SIGNATURE').value=='0#1' || getObj( ainfosection[1] + '_SIGNATURE').value == '0#0'){
			
			//nascondo help
			setVisibility(getObj('help_' + ainfosection[1]),'none');
			
			//nascondo comando firma
			setVisibility(getObj('cmdfirma_' + ainfosection[1]),'none');
			
			try{
				
				/*
				target=getObj('spn_elemento_' + ainfosection[1] + '_' + strAreaOFID + '_' + strIdDztFirma);
				if (document.all != null) //  controllo il browser in uso
					alert(target.style.display);// target.style.display= objState//explorer
				else {
					alert(target.getAttribute("style"));
					//tempState="display:"+objState+";"//netscape
					//target.setAttribute("style", tempState) 
				}
				*/
					
				//nascondo attributo firmabusta
				setVisibility(getObj('spn_elemento_' + ainfosection[1] + '_' + strAreaOFID + '_' + strIdDztFirma),'none');
				
				//nascondo bottone attributo firmabusta
				setVisibility(getObj('div_btn_elemento_' + ainfosection[1] + '_' + strAreaOFID + '_' + strIdDztFirma),'none');
				
				//nascondo caption della busta firma
				setVisibility(getObj('caption_' + ainfosection[1] + '_' + strAreaOFID),'none');				
				
				
			}catch(e){
				//alert(e);
			}

			
			
		}
		
	}
	}

}

//nascondo area allegati della sezione tecnica e della sezione economica in caso di nuovo documento
strdata=getObj('ReceivedDataMsg').value;
if ( strdata > '2009-10-30T00:00:00')
	nHide=1;
if (getObj('Stato').value == '0' || getObj('Stato').value == '1' || nHide==1){
	setVisibility(getObj('DIV_TECNICA_allegati'),'none');	
	setVisibility(getObj('DIV_ECONOMICA_allegati'),'none');
}

 DrawLabel('1'); 
 FUNC_DOCUMENTAZIONE();

</script>

