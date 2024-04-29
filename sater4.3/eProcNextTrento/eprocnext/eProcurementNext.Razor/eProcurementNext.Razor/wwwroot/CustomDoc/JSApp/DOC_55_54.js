

<script language="javascript">


//RIMAPPO LA FUNZIONE DI SEND PER FARE DEI CONTROLLI CUSTOM
var oldSend=PRINT;

function NewSend(){
  
  
  if ( getObj('NumProduct_DOCUMENTAZIONE_griglia').value < 1  ) {
  
	 
      alert('La busta di documentazione deve contenere almeno un allegato');
      DrawLabel('1'); 
      FUNC_DOCUMENTAZIONE();
      return;
  
  }
  
  try{
    if ( getObj('NumProduct_ECONOMICA_attidigara').value < 1 ){
        
        alert('La busta economica deve contenere almeno un allegato');
        DrawLabel('2'); 
        FUNC_ECONOMICA();
        return;
    
    }
  }catch(e){}
  
  
  //controllo se presente che valore offerto è valorizzato
  try{
    var objOfferta = getObj( 'elemento_ECONOMICA_comune_' + get_IdDztFromDztNome_AreaOfid('ECONOMICA_comune','ValoreOfferta') );
    if ( objOfferta.value == '') {
      
      alert( CNVAJAX ('../../' , 'Valore Offerta Obbligatorio' ) );
      DrawLabel('3'); 
      FUNC_ECONOMICA();
      return false;
      
    }
  }catch(e){}
  
	//controllo le sezioni da firmare abbiano la firma
	var infotab=getObj('INFOTAB').value;
	var ainfotab=infotab.split('#~');
	strCheck='SENDGENERIC()';
	for (i=0; i < ainfotab.length; i++){
		
    ainfosection = ainfotab[i].split('~');
		hidesection  = getObj( ainfosection[1] + '_Hide').value;
		if (hidesection == '0')
			strCheck = strCheck + ' && SEND_' + ainfosection[1] + '() '	;
			
	}
        	
	if ( !  eval(strCheck) )
    return;
		
  if ( ExecEvent("SEND") != 0 )
    return ;
  
  
      
    
    else{
      
  	  for (i=0; i < ainfotab.length; i++){
  		
    		ainfosection= ainfotab[i].split('~');
    		
    		signsection=getObj( ainfosection[1] + '_SIGNATURE').value;
    		hidesection=getObj( ainfosection[1] + '_Hide').value;
    
    		if ( signsection == '0#1' && hidesection == '0' ){
    			
      			//determino attributo di firma
      			try{
      			 ListAttrib = getObj('ListAttrib_' + ainfosection[1] + '_firma' ).value;
      			}catch(e){
              ListAttrib ='';
            }
      			
      			if (ListAttrib != ''){
      				ainfo=ListAttrib.split('#');
      				nNumComune=ainfo.length;
      				for (j=0; j < ainfo.length; j++){
      					InfoAttrib=ainfo[j];
      					ainfo1=ainfo[j].split(';');
      							
      					if (ainfo1[0] == 'FirmaBusta'){
      						strIdDztFirma=ainfo1[1];
      					
      					}				
      				}
      			}
      			
      			
      			if ( getObj('spn_elemento_' + ainfosection[1] + '_firma_' + strIdDztFirma ).style.display == ''){
      				if ( getObj( ainfosection[1] + '_IdFirma').value == '' ){
      					DrawLabel(i); 
                eval('FUNC_'+ ainfosection[1] + '()');
                alert('Busta ' +  ainfosection[1] +': genera il PDF della sezione, firma il file e allegalo alla sezione');
      					return;
      				}
      				
      				if ( getObj('elemento_' + ainfosection[1] + '_firma_' + strIdDztFirma ).value == ''){
      				  DrawLabel(i); 
                eval('FUNC_'+ ainfosection[1] + '()');
      					alert('Busta ' +  ainfosection[1] +': allegare il PDF firmato della sezione');
      					return;
      				}
      			}	
      			
    		}
  
  	 }
  	 
    }	 
    
    
	
	//INNESCO VECCHIA FUNZIONE
  oldSend('');
  
}

PRINT = NewSend ;	


window.onload = InitOfferta ;

function InitOfferta() {
  
  //nascondo area allegati della sezione tecnica e della sezione economica in caso di nuovo documento
  try{
	nHide=0;

	try{
		strdata=getObj('ReceivedDataMsg')[0].value;
	}catch(e){
		strdata=getObj('ReceivedDataMsg').value;
	}

	
	if ( strdata > '2009-10-30T00:00:00')
		nHide=1;

	if (getObj('Stato').value == '0' || getObj('Stato').value == '1' || nHide==1){
		setVisibility(getObj('DIV_TECNICA_allegati'),'none');	
		setVisibility(getObj('DIV_ECONOMICA_allegati'),'none');
	}

  }catch(e){
  }

  //DrawLabel('1'); 
  //FUNC_DOCUMENTAZIONE();

}


//MULTILINGUISMO AJAX
function CNVAJAX( path , testo ){
	  
	  
  	ajax = GetXMLHttpRequest(); 
  
  	if(ajax){
  				 
  		
  			ajax.open("GET", path + 'CTL_Library/functions/CNV.asp?TXT=' + escape( testo ), false);
  	 		 
  			ajax.send(null);
  			
  			if(ajax.readyState == 4) {
  			  
  				if(ajax.status == 200)
  				{
  				  
  					return ajax.responseText;
  				}
  			}
  
  	}
  	return testo;
}

</script>