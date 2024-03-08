<script language="javascript">
 
var ATI_Mandataria = '1' ;
var ATI_Mandante = '2' ;

//dominio assoc. a CriterioAggiudicazioneGara
var PDA_CriterioPrezzobasso	= '15531' ;
var PDA_OffertaVantaggiosa	= '15532' ;
var PDA_CriterioPrezzoAlto	= '16291' ;

var Divisione_lotti_No = '0' ;
var Divisione_lotti_LottiTrad = '1' ;
var Divisione_lotti_Lotti = '2' ;

var Stato_New     = '0';
var Stato_Saved   = '1';
var Stato_Sended  = '2';
 
var Old_Literal_elemento_ECONOMICA_comune_onchange ;
var Old_CheckSignSection = CheckSignSection ;
var oldSend=PRINT ;
var Old_SEND_MicroLotti = SEND_MicroLotti ;
var Old_SEND_DOCUMENTAZIONE = SEND_DOCUMENTAZIONE ;

var w_err=350;
var h_err=150;
var Left_err = (screen.availWidth-w_err)/2;
var Top_err  = (screen.availHeight-h_err)/2;
var strPosition = ',left=' + Left_err + ',top=' + Top_err + ',width=' + w_err + ',height=' + h_err ;
	

//IMPLEMENTA LA NUOVA FUNZIONE DI SEND
function NewSend( param ){
  
  var bret=true;
  
  //se PARAM � vuoto � il SEND e allora faccio i controlli
  if ( param == '' ) {
    
      //CONTROLLO CHE LA BUSTA DI DOCUMENTAZIONE ABBIA UN ALLEGATO
      if ( getObj('NumProduct_DOCUMENTAZIONE_griglia').value < 1 ) {
          
          //ExecFunction( '../../ctl_library/MessageBoxWin.asp?ML=yes&MSG=La busta di documentazione deve contenere almeno un allegato&CAPTION=Attenzione&ICO=2' , 'MSGBOX' , strPosition );
          alert( CNVAJAX ('../../' , 'La busta di documentazione deve contenere almeno un allegato' ) );
          DrawLabel('1'); 
          FUNC_DOCUMENTAZIONE();
          
          return;
          
      }
    
      //CONTROLLO IN CASO DI RTI
      bret = false;
      //var bret=CanSendATI();
      var bret=CanSendRTI();
      if ( ! bret ){
        DrawLabel('1'); 
        FUNC_DOCUMENTAZIONE();
        return;
      }
      
     
      if ( getObj( 'Divisione_lotti' ).value == '2'  ){
        
        bret = false;
        bret = CanSendMicrolotti();
       
        if ( ! bret )
          return;
        
      }
      
      
      //SE NON NASCOSTA CONTROLLO CHE LA BUSTA ECONOMICA ABBIA UN ALLEGATO
      if ( getObj( 'ECONOMICA_Hide' ).value == 0 && getObj('NumProduct_ECONOMICA_economicaallegati').value < 1 ){
      
          //alert('La busta economica deve contenere almeno un allegato');
          //ExecFunction( '../../ctl_library/MessageBoxWin.asp?ML=yes&MSG=La busta economica deve contenere almeno un allegato&CAPTION=Attenzione&ICO=2' , 'MSGBOX' , strPosition );
          alert( CNVAJAX ('../../' , 'La busta economica deve contenere almeno un allegato' ) );
          DrawLabel('3'); 
          FUNC_ECONOMICA();
          return;
          
      }
      
      
      //se CriterioAggiudicazioneGara=Offerta Economicamnete + vantagg. controllo BUSTA TECNICA
      if ( getObj('CriterioAggiudicazioneGara').value == PDA_OffertaVantaggiosa && getObj('Divisione_lotti').value == Divisione_lotti_No){
        
        //se nella busta tecnica ci sono criteri a quiz controllo che siano valorizzati 
        if ( ! CheckCriteriQuizCompiled() ){
          alert(CNVAJAX ('../../' , 'Inserire il valore per il criterio quiz nella busta tecnica' ));
          DrawLabel('2'); 
	        FUNC_TECNICA();
	        return;
        }
        
          
      }
      
      //CONTROLLO SEND BASE
      
      bret = false;
      var bret=CanSendBase();
      if ( ! bret )
        return;
      
      
      //CHIEDO CONFERMA SE IL FORNITORE STA PARTECIPANDO  ALLA GARA ANCHE IN UN RAGGRUPPAMENTO RTI
      var nCheckRTI=0;
      nCheckRTI = CheckFornitoreInRTI();
  
      if ( nCheckRTI == 1 ){
        if (  confirm( CNV ('../../' , 'Stai Partecipando alla Gara in Forma Indiretta. Vuoi continuare' ) ) == false ) 
          return ;
      }      
    
  }
  
  //innesco la vecchia funzione legata al SEND
  oldSend( param );

}

PRINT = NewSend ;	



//IMPLEMENTA I CONTROLLI IN CASO DI ATI(SE TUTTO COMILATO CORRETTAMENTE)
function CanSendATI(){

  //controllo se ho compilato coerentemente le info per ATI
  var objDenominazioneATI = getObj( 'elemento_DOCUMENTAZIONE_comuneATI_' + get_IdDztFromDztNome_AreaOfid('DOCUMENTAZIONE_comuneATI','DenominazioneATI') );
  
  var NumRowAti = getObj('NumProduct_DOCUMENTAZIONE_ATIgriglia').value
  
  if ( objDenominazioneATI.value != '' || NumRowAti > 0 ) {
      
      //controllo che ho inserito descrizione ATI
      if ( objDenominazioneATI.value == '' ){
        
        alert( CNVAJAX ('../../' , 'Inserire la denominazione ATI' ) );
        //ExecFunction( '../../ctl_library/MessageBoxWin.asp?ML=yes&MSG=Inserire la denominazione ATI&CAPTION=Attenzione&ICO=2' , 'MSGBOX' , strPosition );
        DrawLabel('1'); 
        FUNC_DOCUMENTAZIONE();
        return false;
        
      }

      //controllo che ho compilato correttamente la struttura ATI
      var nomeCompletoGriglia = 'DOCUMENTAZIONE_ATIgriglia';
      var colPos1 = -1 ;
      var colPos2 = -1 ;
      var colPos3 = -1 ;
      var colPos4 = -1 ;
      var colPos5 = -1 ;
      var colPos6 = -1 ;
      var Objfield1 , Objfield2 , Objfield3 , Objfield4 , Objfield5 , Objfield6 ;
      var nIsMandataria = 0;
      var nIsMandante = 0;
      
      for ( nIndRrow=1; nIndRrow<=NumRowAti; nIndRrow++ ){
        
          colPos1 = GetColumnPositionInGrid('RAGSOC',nomeCompletoGriglia);
				  Objfield1 = getObj(nomeCompletoGriglia + '_' + nIndRrow + '_' + colPos1);
				  
				  colPos2 = GetColumnPositionInGrid('codicefiscale',nomeCompletoGriglia);
				  Objfield2 = getObj(nomeCompletoGriglia + '_' + nIndRrow + '_' + colPos2);
				  
				  colPos3 = GetColumnPositionInGrid('INDIRIZZOLEG',nomeCompletoGriglia);
				  Objfield3 = getObj(nomeCompletoGriglia + '_' + nIndRrow + '_' + colPos3);
				  
          colPos4 = GetColumnPositionInGrid('LOCALITALEG',nomeCompletoGriglia);
				  Objfield4 = getObj(nomeCompletoGriglia + '_' + nIndRrow + '_' + colPos4);
				  
          colPos5 = GetColumnPositionInGrid('PROVINCIALEG',nomeCompletoGriglia);
				  Objfield5 = getObj(nomeCompletoGriglia + '_' + nIndRrow + '_' + colPos5);
				  
          colPos6 = GetColumnPositionInGrid('Ruolo_Impresa',nomeCompletoGriglia);
				  Objfield6 = getObj(nomeCompletoGriglia + '_' + nIndRrow + '_' + colPos6);
				  
				  if (Objfield6.value == ATI_Mandataria){
				    nIsMandataria = 1;
				  }
				  
				  if (Objfield6.value == ATI_Mandante){
				    nIsMandante = 1;
				  }
				  
          if ( Objfield1.value == '' || Objfield2.value == '' || Objfield3.value == '' || Objfield4.value == '' || Objfield5.value == '' || Objfield6.value == '' ){
            
            alert( CNVAJAX ('../../' , 'Le info della struttura ATI non sono complete' ) );
            //ExecFunction( '../../ctl_library/MessageBoxWin.asp?ML=yes&MSG=Le info della struttura ATI non sono complete&CAPTION=Attenzione&ICO=2' , 'MSGBOX' , strPosition );
            DrawLabel('1'); 
            FUNC_DOCUMENTAZIONE();
            return false;
            
          }
          
      
      }
      
      //controllo che � settata la mandataria
      if ( nIsMandataria == 0 ) {
        alert( CNVAJAX ('../../' , 'inserire la Mandataria ATI' ) );
        //ExecFunction( '../../ctl_library/MessageBoxWin.asp?ML=yes&MSG=inserire la Mandataria ATI&CAPTION=Attenzione&ICO=2' , 'MSGBOX' , strPosition );
        DrawLabel('1'); 
        FUNC_DOCUMENTAZIONE();
        return false;  
      
      }     
      
      
      //controllo che � settata la mandante
      if ( nIsMandante == 0 ) {
        alert( CNVAJAX ('../../' , 'inserire la Mandante ATI' ) );
        //ExecFunction( '../../ctl_library/MessageBoxWin.asp?ML=yes&MSG=inserire la Mandante ATI&CAPTION=Attenzione&ICO=2' , 'MSGBOX' , strPosition );
        DrawLabel('1'); 
        FUNC_DOCUMENTAZIONE();
        return false;  
      
      }   
      
  }
  
  return true;
  
}

//CONTROLLA CHE IN CASO DI RTI LA COMPILAZIONE E' OK
function CanSendRTI(){
  
  var bret=false;
  
  //controllo se partecipacomeRTI � settato che la griglia RTi � compilata correttamente
  bret = CanSendGridRTI( 'DOCUMENTAZIONE_comuneATI', 'DOCUMENTAZIONE_ATIgriglia', 'PartecipaFormaRTI' , 'mandante'   );
  if ( ! bret){
    return false;
  }
  
  //controllo che per la RTI le righe devo essere almeno 2
  objRow=getObj('NumProduct_DOCUMENTAZIONE_ATIgriglia');
  nNumRow=Number(objRow.value);
  if (nNumRow != 0 &&  nNumRow == 1){
      
    alert( CNV ('../../' , 'inserire almeno una mandante') );
    return false;
    
  }
  
  //se ho settato Consorzio a si controllo che la griglia consorzio � compilata correttamente
  bret=false;
  bret = CanSendGridRTI( 'DOCUMENTAZIONE_ComuneConsorzio', 'DOCUMENTAZIONE_Consorziogriglia', 'InserisciEsecutriciLavori' , 'esecutrice'   )
  if ( ! bret){
    return false;
  }
  
  //controllo che i consorzi della griglia Consorzio sono tutti nella griglia RTI
  bret=false;
  bret = RiferimentiGridIsInRTI( 'DOCUMENTAZIONE_Consorziogriglia' , 'RagSocConsorzio' , 'IdAziConsorzio'  );
  if ( ! bret){
    return false;
  }
  
  //se ho settatto RicorriAvvalimento controllo che la griglia avvalimento � compilata correttamente
  bret=false;
  bret = CanSendGridRTI( 'DOCUMENTAZIONE_ComuneAvvalimento', 'DOCUMENTAZIONE_Avvalimentogriglia', 'RicorriAvvalimento' , 'ausiliaria'   )
  if ( ! bret){
    return false;
  }
	
	//controllo che le ausiliate  della griglia Avvalimenti sono tutti nella griglia RTI
  bret=false;
  bret = RiferimentiGridIsInRTI( 'DOCUMENTAZIONE_Avvalimentogriglia' , 'RagSocAusiliata', 'IdAziAusiliata' );
  if ( ! bret){
    return false;
  }
	
  return true;
  
}


function CanSendGridRTI( strFullAreaNameOfid, strFullNameArea, strAttrib , strCnv   ){

  
  var iddztAttrib;
  var objAttrib;
  
  iddztAttrib = get_IdDztFromDztNome_AreaOfid( strFullAreaNameOfid , strAttrib );
  //objAttrib = getObj('elemento_' + strFullAreaNameOfid + '_' + iddztAttrib ) ;
  objAttrib = eval ( 'document.new_document.elemento_' + strFullAreaNameOfid + '_' + iddztAttrib )	 ;
  
  for (r=0; r < objAttrib.length; r++){
		if ( objAttrib[r].checked == true)
			strvalue = objAttrib[r].value;
	}
  
  if ( strvalue == '1'){
    
    nPosDesc=GetColumnPositionInGrid('RAGSOC',strFullNameArea);
    objRow=getObj('NumProduct_'+ strFullNameArea);
    nNumRow=Number(objRow.value);
    
    if (nNumRow == 0 ){
      
      alert( CNV ('../../' , 'inserire almeno una ' + strCnv ) );
      return false;
       
    }else{
    
      for ( nIndRrow=1; nIndRrow <= nNumRow; nIndRrow++){	
        
        if ( getObj(strFullNameArea + '_' + nIndRrow + '_' + nPosDesc ).value == '' ){
          
          alert( CNV ('../../' , 'inserire codice fiscale della ' + strCnv ) );
          return false;
          
        }
      }    
    }
  }
  
  return true;
  
}

//IMPLEMENTA I CONTROLLI SEND BASE DEL DOCUMENTO
function CanSendBase(){

  //SEND BASE
	var infotab=getObj('INFOTAB').value;
	var ainfotab=infotab.split('#~');
	strCheck='SENDGENERIC()';
	
	for (i=0; i < ainfotab.length; i++){
		
    ainfosection = ainfotab[i].split('~');
		hidesection  = getObj( ainfosection[1] + '_Hide').value;
		if (hidesection == '0')
			strCheck = strCheck + ' && SEND_' + ainfosection[1] + '() '	;
			
	}
	
	if ( ! eval(strCheck) )
    return false;
		
  if ( ExecEvent("SEND") != 0 )
   return false;
    
  
  //CONTROLLO LE AREE DI FIRMA SE VALORIZZATE  
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
    			
      			if ( getObj('spn_elemento_' + ainfosection[1] + '_firma_' + strIdDztFirma ).style.display == ''){
      				
              if ( getObj( ainfosection[1] + '_IdFirma').value == '' ){
      				  
      				  DrawLabel(i); 
                eval('FUNC_'+ ainfosection[1] + '()');
      					//alert('Busta ' +  ainfosection[1] +': genera il PDF della sezione, firma il file e allegalo alla sezione');
      					strMSG = 'Busta ' +  ainfosection[1] +': genera il PDF della sezione, firma il file e allegalo alla sezione';
      		      //ExecFunction( '../../ctl_library/MessageBoxWin.asp?ML=no&MSG=' + strMSG + '&CAPTION=Attenzione&ICO=2' , 'MSGBOX' , strPosition );
      		      alert( CNVAJAX ('../../' , strMSG ) );
      					return false;
      				}
      				
      				if ( getObj('elemento_' + ainfosection[1] + '_firma_' + strIdDztFirma ).value == ''){
      				
      				  DrawLabel(i); 
                eval('FUNC_'+ ainfosection[1] +'()');
               	//alert('Busta ' +  ainfosection[1] +': allegare il PDF firmato della sezione');
               	strMSG = 'Busta ' +  ainfosection[1] +': allegare il PDF firmato della sezione' ; 
               	//ExecFunction( '../../ctl_library/MessageBoxWin.asp?ML=no&MSG=' + strMSG + '&CAPTION=Attenzione&ICO=2' , 'MSGBOX' , strPosition );
               	alert( CNVAJAX ('../../' , strMSG ) );
      					return false;
      				}
      			}	
  			}
		}
  }
  
  return true;
}

//IMPLEMENTA I CONTROLLI SEND PER I MICROLOTTI
function CanSendMicrolotti(){

  //controllo sia allegato un modello
  var objMicrolottoAllegato = getObj( 'elemento_MicroLotti_MicrolottoComune_' + get_IdDztFromDztNome_AreaOfid('MicroLotti_MicrolottoComune','MicrolottoAllegatoOfferta') );
  if ( objMicrolottoAllegato.value == '') {
  
    alert( CNVAJAX ('../../' , 'Allegare offerta microlotto' ) );
    //ExecFunction( '../../ctl_library/MessageBoxWin.asp?ML=yes&MSG=Allegare offerta microlotto&CAPTION=Attenzione&ICO=2' , 'MSGBOX' , strPosition );
    DrawLabel('4'); 
    FUNC_MicroLotti();
    getObj( 'Button_elemento_MicroLotti_MicrolottoComune_' + get_IdDztFromDztNome_AreaOfid('MicroLotti_MicrolottoComune','MicrolottoAllegatoOfferta') ).focus();
    return false;
    
  }
  
	
  
  //innesco controllo dei microlotti
  var strEsitoCanSend = ExecProcessAjax( getObj("lIdMsgPar").value , "SEND_MICROLOTTI,OFFERTA" )
  //alert (strEsitoCanSend) ;
	var info=strEsitoCanSend.split('###');
	if( info[0] != '0' ) {
	
		try {
			target=getObj('LNK_Send_1');
			setClassName(target, 'FontTextLinkRiepilogo');
			target.onclick=TempClick;

			target=getObj('SPN_Send_1');
			setClassName(target, 'FontTextLinkRiepilogo');
			target.onclick=TempClick;
		}catch(e){
		}
		
    DrawLabel('4'); 
    FUNC_MicroLotti();
    
		//visualizzo messaggio di errore
		ExecFunction( '../../ctl_library/MessageBoxWin.asp?ML=no&MSG=' + info[2] +'&CAPTION=' + info[1] + '&ICO=' + info[3] , 'MSGBOX' , strPosition );
   	return false;
   	
	}
  
  
  //se richiesta la firma controllo che ho allegato il pdf firmato della busta MICROLOTTI
  var strValueSignMicrolotti = getObj("MicroLotti_SIGNATURE").value;
  if ( strValueSignMicrolotti == '0#1' ){
    
    if ( getObj( 'elemento_MicroLotti_firma_' + get_IdDztFromDztNome_AreaOfid('MicroLotti_firma','FirmaBusta') ).value  == ''){
    
        //ExecFunction( '../../ctl_library/MessageBoxWin.asp?ML=yes&MSG=Allegare offerta microlotto firmata&CAPTION=Attenzione&ICO=2' , 'MSGBOX' , strPosition );
        alert( CNVAJAX ('../../' , 'Allegare offerta microlotto firmata' ) );
        DrawLabel('4'); 
        FUNC_MicroLotti();
        return false;
        
    }
  }
  
  //se richiesta la cauzione controllo che ho allegato il pdf firmato della busta DOCUMENTAZIONE
  var strValueSignCauzione = getObj("DOCUMENTAZIONE_SIGNATURE").value;
  if ( strValueSignCauzione == '0#1' ){
    
    if ( getObj( 'elemento_DOCUMENTAZIONE_firma_' + get_IdDztFromDztNome_AreaOfid('DOCUMENTAZIONE_firma','FirmaBusta') ).value  == ''){
    
        alert( CNVAJAX ('../../' , 'Allegare cauzione microlotto firmata' ) );
        //ExecFunction( '../../ctl_library/MessageBoxWin.asp?ML=yes&MSG=Allegare cauzione microlotto firmata&CAPTION=Attenzione&ICO=2' , 'MSGBOX' , strPosition );
        DrawLabel('1'); 
        FUNC_DOCUMENTAZIONE();
        return false;
        
    }
  }
  
  return true;

}



//rimappo la funzione che controlla se una sezione � da firmare per
//resettare anche la cauzione quando cambia la busta Microlotti
//e per non fare nulla se cambia la busta documentazione
function NewCheckSignSection( strTabName ){
  
  if ( strTabName != 'DOCUMENTAZIONE' ) {
    Old_CheckSignSection(strTabName);
    
    //nel caso dei microlotti  
    if ( getObj( 'Divisione_lotti' ).value == '2'  ){
      ResetFirmaCauzione();
    }
    
  }
}

CheckSignSection = NewCheckSignSection ;



//RIMAPPO FUNZIONE CHE CONTROLLA LA SEZIONE MICROLOTTI
//INVOCATA PRIMA DI FARE GENERA PDF E PRIMA DI FARE IL SEND
function New_SEND_MicroLotti(){
  
  
  //controllo sia allegato un modello
  if ( getObj( 'Divisione_lotti' ).value == '2'  ){
    
    Old_SEND_MicroLotti();
    
    var objMicrolottoAllegato = getObj( 'elemento_MicroLotti_MicrolottoComune_' + get_IdDztFromDztNome_AreaOfid('MicroLotti_MicrolottoComune','MicrolottoAllegatoOfferta') );
    if ( objMicrolottoAllegato.value == '') {
    
      alert( CNVAJAX ('../../' , 'Allegare offerta microlotto' ) );
      //ExecFunction( '../../ctl_library/MessageBoxWin.asp?ML=yes&MSG=Allegare offerta microlotto&CAPTION=Attenzione&ICO=2' , 'MSGBOX' , strPosition );
      DrawLabel('4'); 
      FUNC_MicroLotti();
      getObj( 'Button_elemento_MicroLotti_MicrolottoComune_' + get_IdDztFromDztNome_AreaOfid('MicroLotti_MicrolottoComune','MicrolottoAllegatoOfferta') ).focus();
      return false;
    }
    
    //controllo che non ci siano anomalie invocando processo microlotti
    var strEsitoCanSend = ExecProcessAjax( getObj("lIdMsgPar").value , "SEND_MICROLOTTI,OFFERTA" )
    //alert (strEsitoCanSend) ;
    var info=strEsitoCanSend.split('###');
    if( info[0] != '0' ) {
    
      DrawLabel('4'); 
      FUNC_MicroLotti();
      
    	//visualizzo messaggio di errore
    	ExecFunction( '../../ctl_library/MessageBoxWin.asp?ML=no&MSG=' + info[2] +'&CAPTION=' + info[1] + '&ICO=' + info[3] , 'MSGBOX' , strPosition );
     	return false;
     	
    }
    
  }
  
  return true;
  
}

SEND_MicroLotti = New_SEND_MicroLotti ;


//RIMAPPO FUNZIONE CHE CONTROLLA LA SEZIONE MICROLOTTI
//INVOCATA PRIMA DI FARE GENERA PDF E PRIMA DI FARE IL SEND
function New_SEND_DOCUMENTAZIONE(){
  
  
  var bret=Old_SEND_DOCUMENTAZIONE();
  
  if ( ! bret)
      return false;
      
  
  //nel caso di microlotti devo aver inserito anche un foglio per l'offerta nei microlotti
  if ( getObj( 'Divisione_lotti' ).value == '2'  ){
    var objMicrolottoAllegato = getObj( 'elemento_MicroLotti_MicrolottoComune_' + get_IdDztFromDztNome_AreaOfid('MicroLotti_MicrolottoComune','MicrolottoAllegatoOfferta') );
    if ( objMicrolottoAllegato.value == '') {
    
      alert( CNVAJAX ('../../' , 'Allegare offerta microlotto' ) );
      //ExecFunction( '../../ctl_library/MessageBoxWin.asp?ML=yes&MSG=Allegare offerta microlotto&CAPTION=Attenzione&ICO=2' , 'MSGBOX' , strPosition );
      DrawLabel('4'); 
      FUNC_MicroLotti();
      getObj( 'Button_elemento_MicroLotti_MicrolottoComune_' + get_IdDztFromDztNome_AreaOfid('MicroLotti_MicrolottoComune','MicrolottoAllegatoOfferta') ).focus();
      return false;
      
    }
  }
  
  return true;
  
}

SEND_DOCUMENTAZIONE = New_SEND_DOCUMENTAZIONE ;


window.onload = InitOfferta ;

//INIZIALIZZAZIONE   
function InitOfferta() {
  
  
  //VISUALIZZO LA BUSTA DI DOCUMENTAZIONE DI DEFAULT
  if ( getObj('strActiveTabName').value == ''){
    DrawLabel('1'); 
    FUNC_DOCUMENTAZIONE(); 
  }
  
  //CAMBIO ON CHANGE DELL'ATTRIBUTO ValoreOffertaLavori per valorizzare il campo letterale e disabilitare ValoreOffertaLavori                                                                               
  try{                                                                            
  
    //recupero attributo ValoreOffertaLavori
    var hObjAttr;                                                                
    hObjAttr = getObj( 'Vis_elemento_ECONOMICA_comune_' + get_IdDztFromDztNome_AreaOfid('ECONOMICA_comune','ValoreOffertaLavori') );                          
    
    //conservo vecchio onblur di ValoreOffertaLavori
    Old_Literal_elemento_ECONOMICA_comune_onchange = hObjAttr.onblur;                                
    
    //setto nuovo onblur di ValoreOffertaLavori
    hObjAttr.onblur =  Literal_elemento_ECONOMICA_comune_onchange;                                  
    
    //cambio desc attributo valore offerta busta economica
    var objDescValore =getObj( 'spn_elemento_ECONOMICA_comune_' + get_IdDztFromDztNome_AreaOfid('ECONOMICA_comune','ValoreOffertaLavori') );
    objDescValore.innerHTML = objDescValore.innerHTML + ' (calcolato in automatico)';
    
    //se valoreoffertalavori � 0 e lo stato non � inviato rilancio il calcolo totale della griglia economica
    //perch� ho invertito l'ordine della griglia e dell'area comune che 
    //contiene l'attributo destinazione dove metto il totale e la prima volta non funziona
    var objAttrTech = getObj( 'elemento_ECONOMICA_comune_' + get_IdDztFromDztNome_AreaOfid('ECONOMICA_comune','ValoreOffertaLavori') ) ;	
    var ValoreOffertaTecnico = objAttrTech.value ; 
    if ( ( getObj('Stato').value == Stato_New || getObj('Stato').value == Stato_Saved ) && ValoreOffertaTecnico <= 0) 	
	   CalculateTotal('ECONOMICA_griglia');
    
  }catch(e){ 
    
    //setto comunque nuovo onblur di ValoreOffertaLavori                                                                           
     try{ hObjAttr.onblur =  Literal_elemento_ECONOMICA_comune_onchange; }catch(e){ }                                
  } 
  
  
  
  
  //GESTIONE IN FUNZIONE DEI LOTTI
  HandleCampiMicroLotti();
  
   
  //Nascondo attributi a prescindere
  HideAttrib();
  
  //gestione aree RTI,CONSORZIO,AVVALIMENTO se non richieste
  HandleAreeRTI();
  
  
  //EVIDENZIO SE IL FORNITORE PARTECIPA ALLA GARA IN UN RAGGRUPPAMENTO
  if ( getObj('Stato').value == Stato_New || getObj('Stato').value == Stato_Saved ){
    
    //Se non sono nel contesto INWORK del documento
  	if ( getQSParamFromString(window.location.toString(),'Provenienza') != 'INWORK'){	
      
  		var nCheckRTI=0;
  		nCheckRTI = CheckFornitoreInRTI();
  		
  		if ( nCheckRTI == 1 )
  		  alert( CNVAJAX ('../../' , 'Stai Partecipando alla Gara in Forma Indiretta' ) );
  	}	
  	
  	//visualizzo messaggio informnativo se bando scaduto
  	var ScadenzaBando=getObj('ExpiryDateOrigin').value;
  	//alert(ScadenzaBando);
  	
  	if ( ScadenzaBando <= DataOrarioServer )
  	 alert( CNVAJAX ('../../' , 'Bando Scaduto - offerta non utilizzabile' ) );
  }
}
   

//SETTA IL CAMPO LETTERALE DELLA BUSTA ECONOMICA TotaleInLettere in funzione del campo numerico ValoreOffertaLavori 
function Literal_elemento_ECONOMICA_comune_onchange()
{                                                                               
                                                                               
   var hObjAttrFix;                                                               
   var hObjAttrDec;                                                            
   var nValue;                                                                 
   var hObjAttrDest;                                                           
   var sDecimal;                                                               
   var strValueLiteral;                                                                            
  
   //eseguo vecchio onblur di ValoreOffertaLavori
   try{                                                                        
       Old_Literal_elemento_ECONOMICA_comune_onchange();                                             
   }catch(e){}                                                                 
                                                                               
   try{                                                                        
      
      //recupero valore di ValoreOffertaLavori
      hObjAttrValue = getObj( 'elemento_ECONOMICA_comune_' + get_IdDztFromDztNome_AreaOfid('ECONOMICA_comune','ValoreOffertaLavori') );                     
      strValue = hObjAttrValue.value;                                          
      
      //recupero la forma letterale del valore di ValoreOffertaLavori espresso in numeri                                                                
      aValue = strValue.split( '.' );                                          
      nValue=aValue[0];                                                        
      if (aValue.length==2)                                                    
           sDecimal=aValue[1];                                                                 
      else                                                                     
           sDecimal='';      
                                                             
      if (IsNumber(sDecimal)==0 || sDecimal=='')                               
           sDecimal='';                                                        
      else                                                                     
           sDecimal='/'+sDecimal;                                              
      strValueLiteral='';                                                                         
                                                                               
      if (IsNumber(nValue)==0)                                                 
           strValueLiteral='';                                                  
      else                                                                     
           strValueLiteral=NumeroInLettere(nValue)+sDecimal;                                                                 
      
      //aggiorno campo nascosto di TotaleInLettere
      hObjAttrDest = getObj( 'elemento_ECONOMICA_comune_' + get_IdDztFromDztNome_AreaOfid('ECONOMICA_comune','TotaleInLettere') );                        
      hObjAttrDest.value=strValueLiteral;                                      
      
      //aggiorno campo a video di TotaleInLettere
      hObjAttrDestVisual = getObj( 'elemento_ECONOMICA_comune_' + get_IdDztFromDztNome_AreaOfid('ECONOMICA_comune','TotaleInLettere') + '_vis' );              
      hObjAttrDestVisual.value=strValueLiteral;                                
                                                                               
   }catch(e){}                                                                 
}    
   
//SETTA LE SEZIONI DELL'OFFERTA IN FUNZIONE del campo Divisione_lotti 
function HandleCampiMicroLotti(){

  var DivisioneLotti;
  
  //se nn essite il campo DivisioneLotti come prima
  try{
    DivisioneLotti = getObj( 'Divisione_lotti' ).value
  } catch(e){DivisioneLotti='';}
  
  if (  DivisioneLotti == '2'  ){
  
    //microlotti nascondo la sezione economica
    hObjSection = getObj( 'ECONOMICA_Hide' );                   
    hObjSection.value = 1 ;     
    
    
    //se selezionato un modello allora carico nell'area URL il viewer
    //per visualizzare il modello di micro lotto caricato
    DisplayAreaUrlMicroLotto();
    
  }else{
    
    //altrimenti nascondo la sezione microlotti
    try{
      hObjSection = getObj( 'MicroLotti_Hide' );                   
      hObjSection.value = 1 ;    
    }catch(e){
    }
  
  }
  
  DrawLabel( LinkAttivo );   


    
}

    
  
//VISUALIZZA AREA VIEWR PER I MICROLOTTI
function DisplayAreaUrlMicroLotto(){

  var objListaModelli = getObj('ListaModelliMicrolotti');
   
  if ( objListaModelli.value != '') {
    
    //alert(getObj('iframe_MicroLotti_MicrolottoUrl').src);
    
    ajax = GetXMLHttpRequest(); 

  	if(ajax){
  				 
  		  ajax.open("GET", '../../CustomDoc/GetInfoModelloMicrolotto.asp?CODICE=' + escape(  objListaModelli.value ), false);
  	 		 
  			ajax.send(null);
  			
        
  			
  			if(ajax.readyState == 4) {
  			
  				if(ajax.status == 200)
  				{
  				
  				  if ( ajax.responseText != '' ) {
  				    var strresult = ajax.responseText;
  				    var ainfo = strresult.split('@@@');
              var ModelloOfferta=ainfo[2];
              //alert(ModelloOfferta);
              getObj('ModelloOffertaMicrolotto').value = ModelloOfferta ;
              
  				  }
  				}
  			}
  
  	}
    
    var IdHeader = getObj('lIdMsgPar').value
    var strURL = '../../DASHBOARD/Viewer.asp?PATHTOOLBAR=../customdoc/&JScript=&Exit=&Table=View_Document_MicroLotti_Dettagli&OWNER=&IDENTITY=ID&TOOLBAR=&DOCUMENT=&AreaAdd=no&CaptionNoML=no&Caption=&Height=0,100*,210&numRowForPag=25&Sort=&SortOrder=&ACTIVESEL=1&AreaFiltroWin=0&AreaFiltro=no&TOTAL=Totale,4&';  
    var  FilterHide = 'FilterHide=IdHeader=' + IdHeader ;
    strURL = strURL + FilterHide ;
    strURL = strURL + '&ModGriglia=' + ModelloOfferta ;
    getObj('iframe_MicroLotti_MicrolottoUrl').src = strURL;
    
     
  }
 
}     

//RESETTA LA FIRMA DELLA CAUZIONE SE RICHIESTA
function ResetFirmaCauzione(){
   
   
     
   //se richiesta la firma sulla documentazione
   var strValueSignCauzione = getObj("DOCUMENTAZIONE_SIGNATURE").value;
   if ( strValueSignCauzione == '0#1' ){
      
      //se la busta Microlotti � da firmare ed � stata resettata la firma per un cambiamento
      if ( getObj('MicroLotti_SIGNATURE').value == '0#1'  && getObj('MicroLotti_IdFirma').value == '' ) {
      
        var objFirma = getObj( 'elemento_DOCUMENTAZIONE_firma_' + get_IdDztFromDztNome_AreaOfid('DOCUMENTAZIONE_firma','FirmaBusta') );
  			objFirma.value='';
  			
  			var objFirma1=getObj( 'elemento_DOCUMENTAZIONE_firma_' + get_IdDztFromDztNome_AreaOfid('DOCUMENTAZIONE_firma','FirmaBusta') + '_path' );
  			objFirma1.value='';
  			
        var objFirma2=getObj( 'elemento_DOCUMENTAZIONE_firma_' + get_IdDztFromDztNome_AreaOfid('DOCUMENTAZIONE_firma','FirmaBusta') + '_div' ); 
  			objFirma2.innerHTML='';
  							
  			
  			//resetto campo che contiene id blob del pdf
  			getObj('DOCUMENTAZIONE_IdFirma').value='';
  			
  			//visualizzo bottone per selezionare la firma
  			var objFirma3 =  getObj('div_btn_elemento_' + get_IdDztFromDztNome_AreaOfid('DOCUMENTAZIONE_firma','FirmaBusta') );
  			setVisibility(objFirma3 , '');
  		}
  }
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
  


//ritorna la desc relativo all'attributo Quiz della griglia
function GetDescriptionforQuiz( objName ){
  
  var aInfo;
  var nIndRrow;
  
  
  aInfo = objName.split('_');
  
  nIndRrow = aInfo[2];
  
  var strNameControl='TECNICA_griglia' ;
  var nPos=GetColumnPositionInGrid('DescrAttach',strNameControl);
  var strDesc ; 
  
  try{
    strDesc  = getObj(strNameControl + '_' + nIndRrow + '_' + nPos ).value ;
  }catch(e){
    strDesc  = getObj('cell_' + strNameControl + '_' + nIndRrow + '_' + nPos ).innerHTML ;
  }
  

  //strDesc = replace_special_charset(strDesc);
  //strDesc = escape( strDesc) ;
  return  strDesc;
}


//controlla che se ci sono criteri a quiz nella busta tecnica siano compilati i valori
function CheckCriteriQuizCompiled(){
  
  
  
  var strFullNameArea='TECNICA_griglia' ; 
  var strAttribTecnica = getObj('DZTNOME_' + strFullNameArea ).value;
  if ( strAttribTecnica.indexOf('CriterioDiValutazioneQuiz', 0) >= 0 ){
    
      var nPos=GetColumnPositionInGrid('CriterioDiValutazioneQuiz',strFullNameArea);
      var objRow=getObj('NumProduct_'+ strFullNameArea);
      var nNumRow=Number(objRow.value);
      var nIndRrow;
      var strCriterio;
      var objCampoValore;
      for ( nIndRrow=1; nIndRrow<=nNumRow; nIndRrow++){	
        
        //setClassName( getObj('cell_' + strFullNameArea + '_' + nIndRrow +'_'+ nPos), 'Cell1GridProducts1'); 
        getObj('cell_' + strFullNameArea + '_' + nIndRrow +'_'+ nPos).className ='Cell1GridProducts1';
        
        strCriterio = getObj(strFullNameArea + '_' + nIndRrow + '_' + nPos ).value ;
        
        if ( strCriterio.indexOf('#=#range#=#', 0) >= 0 ){
            
            objCampoValore = getObj(strFullNameArea + '_' + nIndRrow + '_' + nPos + '_Numero' ) ;
            //alert(objCampoValore.value);
            if ( objCampoValore.value == ''){
              //getObj( 'Vis_' + strFullNameArea + '_' + nIndRrow + '_' + nPos + '_Numero' ).focus();
              try{
              
                //alert( getObj('cell_' + strFullNameArea + '_' + nIndRrow +'_'+ nPos).className ) ;
                getObj('cell_' + strFullNameArea + '_' + nIndRrow +'_'+ nPos).className ='Value_Obblig';
                //setClassName( getObj('cell_' + strFullNameArea + '_' + nIndRrow +'_'+ nPos), 'Value_Obblig');
                //alert('set class');
              }catch(e){alert('err set class');}
              return false;
            }    
            
        }else{
            
            objCampoValore = getObj(strFullNameArea + '_' + nIndRrow + '_' + nPos + '_Testo' ) ;
            //alert(objCampoValore);
            if ( objCampoValore.selectedIndex == 0 ){
              //getObj( strFullNameArea + '_' + nIndRrow + '_' + nPos + '_Testo' ).focus();
              //objCampoValore.focus();
              //setClassName( getObj('cell_' + strFullNameArea + '_' + nIndRrow +'_'+ nPos), 'Value_Obblig');
              getObj('cell_' + strFullNameArea + '_' + nIndRrow +'_'+ nPos).className ='Value_Obblig';
              return false;
            }
              
        }
        
         
        
      }
  }
  
  return true;
  
}


  //nascondo attributi a prescindere
  function HideAttrib(){
    
    //nascondo colonna valorestandard griglia economica
    ShowCol( 'ECONOMICA_griglia' , 'AbilitaControlli' , 'none' ); 
    
    //nascondo estensioni ammesse griglia economica	
    ShowCol( 'ECONOMICA_economicaallegati' , 'AttachType' , 'none' ); 
    
  }
  
  
  function HandleAreeRTI(){
    
    //setto onchange sul campo radio per nascondere visualizzare area RTI  
    var PartecipaFormaRTI = get_IdDztFromDztNome_AreaOfid('DOCUMENTAZIONE_comuneATI','PartecipaFormaRTI');
    //var objRTI = getObj('elemento_DOCUMENTAZIONE_comuneATI_' + PartecipaFormaRTI ) ;
    var objRTI = eval ( 'document.new_document.elemento_DOCUMENTAZIONE_comuneATI_' + PartecipaFormaRTI );
     
    if ( getObj('Stato').value != Stato_Sended ){
      for (r=0; r < objRTI.length; r++){
  		    objRTI[r].onchange=ShowHideAreaGriglia;
  		}
  		
  		getObj('elemento_DOCUMENTAZIONE_comuneATI_' + PartecipaFormaRTI + '_1' ).style.display='inline';
      getObj('elemento_DOCUMENTAZIONE_comuneATI_' + PartecipaFormaRTI + '_2' ).style.display='inline';
  		
		}else{
		  
      getObj('elemento1_DOCUMENTAZIONE_comuneATI_' + PartecipaFormaRTI + '_1' ).style.display='inline';
      getObj('elemento1_DOCUMENTAZIONE_comuneATI_' + PartecipaFormaRTI + '_2' ).style.display='inline';
      
      if (objRTI.value=='0'){
        setVisibility( getObj('DOCUMENTAZIONE_ATIgriglia') , 'none');
        setVisibility( getObj('caption_DOCUMENTAZIONE_ATIgriglia') , 'none');
      } 
      
    }
    
    //setto onchange sul campo radio per nascondere visualizzare area Consorzio  
    var Esecutrice = get_IdDztFromDztNome_AreaOfid('DOCUMENTAZIONE_ComuneConsorzio','InserisciEsecutriciLavori');
    //var objEsec = getObj('elemento_DOCUMENTAZIONE_ComuneConsorzio_' + Esecutrice ) ;
    var objEsec = eval ( 'document.new_document.elemento_DOCUMENTAZIONE_ComuneConsorzio_' + Esecutrice );
     
    if ( getObj('Stato').value != Stato_Sended ){
    
      for (r=0; r < objEsec.length; r++){
  		    objEsec[r].onchange=ShowHideAreaGriglia;
  		}
  		getObj('elemento_DOCUMENTAZIONE_ComuneConsorzio_' + Esecutrice + '_1' ).style.display='inline';
      getObj('elemento_DOCUMENTAZIONE_ComuneConsorzio_' + Esecutrice + '_2' ).style.display='inline';
  	}else{
      
      getObj('elemento1_DOCUMENTAZIONE_ComuneConsorzio_' + Esecutrice + '_1' ).style.display='inline';
      getObj('elemento1_DOCUMENTAZIONE_ComuneConsorzio_' + Esecutrice + '_2' ).style.display='inline';
      
      if (objEsec.value=='0'){
        setVisibility( getObj('DOCUMENTAZIONE_Consorziogriglia') , 'none');
        setVisibility( getObj('caption_DOCUMENTAZIONE_Consorziogriglia') , 'none');
      }
    }
    	
		//setto onchange sul campo radio per nascondere visualizzare area Avvalimento 
    var Avvalimento = get_IdDztFromDztNome_AreaOfid('DOCUMENTAZIONE_ComuneAvvalimento','RicorriAvvalimento');
    //var objAvval = getObj('elemento_DOCUMENTAZIONE_ComuneAvvalimento_' + Avvalimento ) ;
    var objAvval = eval ( 'document.new_document.elemento_DOCUMENTAZIONE_ComuneAvvalimento_' + Avvalimento );
    if ( getObj('Stato').value != Stato_Sended ){
    
      for (r=0; r < objAvval.length; r++){
  		    objAvval[r].onchange=ShowHideAreaGriglia;
  		}
      getObj('elemento_DOCUMENTAZIONE_ComuneAvvalimento_' + Avvalimento + '_1' ).style.display='inline';
      getObj('elemento_DOCUMENTAZIONE_ComuneAvvalimento_' + Avvalimento + '_2' ).style.display='inline';
      
    }else{
      
      getObj('elemento1_DOCUMENTAZIONE_ComuneAvvalimento_' + Avvalimento + '_1' ).style.display='inline';
      getObj('elemento1_DOCUMENTAZIONE_ComuneAvvalimento_' + Avvalimento + '_2' ).style.display='inline';
      
      if (objAvval.value=='0'){
        setVisibility( getObj('DOCUMENTAZIONE_Avvalimentogriglia') , 'none');
        setVisibility( getObj('caption_DOCUMENTAZIONE_Avvalimentogriglia') , 'none');
      }
        
    }
    
    if ( getObj('Stato').value != Stato_Sended ){
     
      //se richiesto area RTI
      ShowHideAreaRTI( 'DOCUMENTAZIONE_comuneATI', 'DOCUMENTAZIONE_ATIgriglia', 'PartecipaFormaRTI');
      
      //se richiesto area CONSORZIO
  		ShowHideAreaRTI( 'DOCUMENTAZIONE_ComuneConsorzio', 'DOCUMENTAZIONE_Consorziogriglia', 'InserisciEsecutriciLavori');
  	
      //se richiesto area AVVALIMENTO
      ShowHideAreaRTI( 'DOCUMENTAZIONE_ComuneAvvalimento', 'DOCUMENTAZIONE_Avvalimentogriglia', 'RicorriAvvalimento');
      
      //setto onchange sulla colonna codice fiscale
      SetOnChangeOnCodiceFiscale('DOCUMENTAZIONE_ATIgriglia');
      SetOnChangeOnCodiceFiscale('DOCUMENTAZIONE_Consorziogriglia');
      SetOnChangeOnCodiceFiscale('DOCUMENTAZIONE_Avvalimentogriglia');
      
      //nascondo checkbox della griglia ati per la prima riga
      HideCheck_FirstRow_GrigliaATI();
    }
    
	}
  
  //nasconde e resetta una area griglia oppure la visualizza
  function ShowHideAreaGriglia(){
    
   
    var strNameCtl = this.name ;
    var aInfo = strNameCtl.split('_');
    
    var strFullAreaNameOfid = aInfo[1] + '_' + aInfo[2];
    
    var iddztAttrib= aInfo[3];
    
    var strFullAreaNameGrid='';
    
    if (strFullAreaNameOfid == 'DOCUMENTAZIONE_comuneATI')
      strFullAreaNameGrid='DOCUMENTAZIONE_ATIgriglia';
    
    if (strFullAreaNameOfid == 'DOCUMENTAZIONE_ComuneConsorzio')
      strFullAreaNameGrid='DOCUMENTAZIONE_Consorziogriglia';  
    
    if (strFullAreaNameOfid == 'DOCUMENTAZIONE_ComuneAvvalimento')
      strFullAreaNameGrid='DOCUMENTAZIONE_Avvalimentogriglia';
    
    var strAttrib=get_DztNomeFromIdDzt_AreaOfid(strFullAreaNameOfid,iddztAttrib);
    
    ShowHideAreaRTI( strFullAreaNameOfid , strFullAreaNameGrid , strAttrib );
    
  }
  
  //nascnodo visualizzo aree rti,consorzio,avvalimento
  function ShowHideAreaRTI( strFullAreaNameOfid , strFullAreaNameGrid , strAttrib ){
    
    //se richiesto area RTI
    var iddztAttrib = get_IdDztFromDztNome_AreaOfid( strFullAreaNameOfid , strAttrib );
    //var objAttrib = getObj('elemento_' + strFullAreaNameOfid + '_' + iddztAttrib ) ;
    var objAttrib = eval ( 'document.new_document.elemento_' + strFullAreaNameOfid + '_' + iddztAttrib )	 ;
    var strvalue;
    
    for (r=0; r < objAttrib.length; r++){
			if ( objAttrib[r].checked == true)
  			strvalue = objAttrib[r].value;
		}
		
		//salert(strvalue);
		
   	if ( strvalue == '0' ){
		  
		  var objRow=getObj('NumProduct_' + strFullAreaNameGrid );
      var nNumRow=Number(objRow.value);
      var strRowDelete='';
		  
		  if ( nNumRow > 0 ) {
        
        //se ha righe chiedo conferma per svuotare
        if (  confirm( CNV ('../../' , 'Sei sicuro di cancellare ' + strFullAreaNameGrid ) ) == true) {
  		    
  		    //metto grigiato
  		    parent.getObj('INFO_PROCESS').style.display='';
		      parent.getObj('INFO_PROCESS2').style.display='';
  		    
  		    //svuoto la griglia
          ResetGridRTI ( strFullAreaNameGrid );
  		    
  		    try{setVisibility( getObj('caption_' + strFullAreaNameGrid ) , 'none');}catch(e){}
          setVisibility( getObj('command_' + strFullAreaNameGrid ) , 'none');
  		    setVisibility( getObj(strFullAreaNameGrid) , 'none');
  		    
  		    //tolgo grigiato
  		    parent.getObj('INFO_PROCESS').style.display='none';
		      parent.getObj('INFO_PROCESS2').style.display='none';
  		    
        }else{
          
          //rimetto a chekkato l'area che volevo svuotare
          objAttrib[1].checked = true ;
        
        }
      }else{
        
        try{setVisibility( getObj('caption_' + strFullAreaNameGrid ) , 'none');}catch(e){}
        setVisibility( getObj('command_' + strFullAreaNameGrid ) , 'none');
  		  setVisibility( getObj(strFullAreaNameGrid) , 'none');
      
      }
      
      //aggiorno il campo Denominazione    
      UpgradeDenominazioneRTI(); 
		  
    }else{
      
      if (strvalue == '1'){
        
        try{setVisibility( getObj('caption_' + strFullAreaNameGrid ) , '');}catch(e){}
        setVisibility( getObj('command_' + strFullAreaNameGrid ) , '');
    	  setVisibility( getObj(strFullAreaNameGrid) , '');
        
        
        var objRow=getObj('NumProduct_' + strFullAreaNameGrid);
        var nNumRow=Number(objRow.value);
        
        if ( strFullAreaNameGrid == 'DOCUMENTAZIONE_ATIgriglia' ){
        
          if (nNumRow == 0){
            //se si tratta della griglia RTI inserisco in automatico la prima riga per caricare le info dell'azienda loggata come mandataria
            //metto il grigiato
            parent.getObj('INFO_PROCESS').style.display='';
    	      parent.getObj('INFO_PROCESS2').style.display='';
    	      INSERTARTICLE('5129','1','55','186','','DOCUMENTAZIONE_ATIgriglia','Inserisci mandante','1');
    	    }
    	  } 
    	  
    	  
    	  //cambio desc della colonna codice fiscale 
    		if ( strFullAreaNameGrid == 'DOCUMENTAZIONE_Consorziogriglia' || strFullAreaNameGrid == 'DOCUMENTAZIONE_Avvalimentogriglia' ){
    			var nPosCodFiscale = GetColumnPositionInGrid( 'codicefiscale' ,strFullAreaNameGrid );
    			if ( strFullAreaNameGrid == 'DOCUMENTAZIONE_Consorziogriglia' )
    				getObj('cell_' + strFullAreaNameGrid + '_0_' + nPosCodFiscale ).innerHTML ='Codice Fiscale Esecutrici';
    			else
    				getObj('cell_' + strFullAreaNameGrid + '_0_' + nPosCodFiscale ).innerHTML ='Codice Fiscale Ausiliaria';
    		}
    		
        //aggiorno il campo Denominazione    
        UpgradeDenominazioneRTI(); 
     }
    }
  
  }
  
  //funzione per eseguire azioni su una area griglia
  function CustomActionOnGrid ( strFullNameArea , Param ){
  
    //alert(strFullNameArea + '--' + Param);
    
    //se sto lavorando sulle griglie RTI della busta documentazione aggiungo funzione sulla colonna codice fiscale per ricercare
    SetOnChangeOnCodiceFiscale(strFullNameArea);
    
    var objRow=getObj('NumProduct_' + strFullNameArea);
    var nNumRow=Number(objRow.value);
    
    //se lavoro sulla griglia allegati della busta economica nascondo la colonna estensioni ammesse
    if ( strFullNameArea == 'ECONOMICA_economicaallegati')
	    ShowCol( 'ECONOMICA_economicaallegati' , 'AttachType' , 'none' ); 
    
    //se sono sulla griglia RTI ed  essite 1 sola riga allora carico le info azienda loggata
    if ( strFullNameArea == 'DOCUMENTAZIONE_ATIgriglia' && nNumRow == 1){
      
      //recupero carico info azienda loggata
      var InfoAziLoggata = GetInfoAziendaLoggata();
      
      //le setto sulla prima riga
      SetInfoAziendaRow( strFullNameArea, 1 , InfoAziLoggata );
      
      //tolgo il grigiato
      parent.getObj('INFO_PROCESS').style.display='none';
		  parent.getObj('INFO_PROCESS2').style.display='none'; 
	 	}
    
    //cambio desc della colonna codice fiscale 
    if ( strFullNameArea == 'DOCUMENTAZIONE_Consorziogriglia' || strFullNameArea == 'DOCUMENTAZIONE_Avvalimentogriglia' ){
      
      var nPosCodFiscale = GetColumnPositionInGrid( 'codicefiscale' ,strFullNameArea );
      if ( strFullNameArea == 'DOCUMENTAZIONE_Consorziogriglia' )
    	 getObj('cell_' + strFullNameArea + '_0_' + nPosCodFiscale ).innerHTML ='Codice Fiscale Esecutrici';
      else
    	 getObj('cell_' + strFullNameArea + '_0_' + nPosCodFiscale ).innerHTML ='Codice Fiscale Ausiliaria';
    }
    
    //nascondo check per elimina prima riga griglia RTI
    HideCheck_FirstRow_GrigliaATI();
    
    //aggiorno il contenuto del campo denominazione
    UpgradeDenominazioneRTI();
        
    
  }
  
  //SETTO EVENTO ON CHANGE SULLA COLONNA CODICE FISCALE DELLE GRIGLIE RTI
  function SetOnChangeOnCodiceFiscale( strFullNameArea ){
  
    if ( strFullNameArea == 'DOCUMENTAZIONE_ATIgriglia' || strFullNameArea == 'DOCUMENTAZIONE_Consorziogriglia' || strFullNameArea == 'DOCUMENTAZIONE_Avvalimentogriglia' ){
        
      var nPosDesc=GetColumnPositionInGrid('codicefiscale',strFullNameArea);
      var objRow=getObj('NumProduct_'+ strFullNameArea);
      var nNumRow=Number(objRow.value);
      var nIndRrow;
      for ( nIndRrow=1; nIndRrow<=nNumRow; nIndRrow++){	
        
        if ( nIndRrow ==1 && strFullNameArea == 'DOCUMENTAZIONE_ATIgriglia')
          getObj(strFullNameArea + '_' + nIndRrow + '_' + nPosDesc ).onfocus =  notEditableRigaRTI ;
          
        else{
          getObj(strFullNameArea + '_' + nIndRrow + '_' + nPosDesc ).onkeyup = GetInfoAziendaFromCF ;
          getObj(strFullNameArea + '_' + nIndRrow + '_' + nPosDesc ).onblur = MakeAlertAzienda ;
        }
      }               
    }
    
  }
  
  function notEditableRigaRTI(){
    
    this.onblur();
  }
  
  //ritorna le info azienda loggata
  function GetInfoAziendaLoggata( ) {
    
     
    //carico le info azienda loggata
    ajax = GetXMLHttpRequest(); 

  	if(ajax){
  		  
        ajax.open("GET", '../../ctl_library/functions/infoCurrentUser.asp', false);
  	 		 
  			ajax.send(null);
  			
  			if(ajax.readyState == 4) {
  			 
  				if(ajax.status == 200)
  				{
  			    if ( ajax.responseText != '###' ) {
  			     
  				    var strresult = ajax.responseText;
              //rs("aziragionesociale").value & "#" &  rs("aziTelefono1").value & "#" & rs("azifax").value & "#" & rs("pfuE_Mail").value & "#" & rs("aziIndirizzoLeg").value & "#" & rs("aziLocalitaLeg").value & "#" & rs("aziProvinciaLeg").value 
              var aInfo=strresult.split('#');
              var strresult1 = aInfo[0] + '#' + aInfo[4] + '#' + aInfo[5] + '#' + aInfo[6] + '#' + aInfo[7] + '#' + aInfo[8];
              return strresult1;
            }
            
  				}
  			}
  
  	}
    
    
  }
  
  
  //a partire dal codice fiscale ritorna le info di azienda
  function GetInfoAziendaFromCF( ) {
    
    
    var strNameCtl = this.name;
    var aInfo = strNameCtl.split('_');
    var strFullNameArea = aInfo[0] + '_' + aInfo[1];
    var nIndRrow = aInfo[2];
    
    var strCF=this.value;
    
    if (strCF.length >= 7 ){
      
      
      
      //if  ( bIsUnique ){
      
        //provo a ricercare le info azienda
        ajax = GetXMLHttpRequest(); 
  
      	if(ajax){
      		  
            ajax.open("GET", '../../ctl_library/functions/InfoAziFromCF.asp?FilterHide=azivenditore<>0 and aziacquirente=0&CodiceFiscale=' + escape(strCF), false);
      	 		 
      			ajax.send(null);
      			
      			if(ajax.readyState == 4) {
      			  //alert(ajax.status);
      				if(ajax.status == 200)
      				{
      			    if ( ajax.responseText != '' ) {
      			      
      				    this.style.color='black';
                  var strresult = ajax.responseText;
                  //alert(strresult);
                  SetInfoAziendaRow( strFullNameArea,nIndRrow ,strresult );
                  
                  //faccio alert se azienda presente in altra griglia
                  var bIsUnique = AziIsUnique( strFullNameArea , nIndRrow, strCF );
                  
                }else{
                  
                  //setto i caratteri in rosso
                  this.style.color='red';
                  
                  //svuoto i campi
                  SetInfoAziendaRow( strFullNameArea,nIndRrow ,'#####' );
                  
                  //alert(CNV ('../../' , 'codice fiscale azienda non esistente'));
                   
                }
           		}
      			}
      
      	}
      //}else{
        
        //svuoto il campo del CF che non � univoco
      //  this.value='';
        
      //}
    }else{
      //setto i caratteri in rosso
      this.style.color='red';
                  
      //svuoto i campi
      SetInfoAziendaRow( strFullNameArea,nIndRrow ,'#####' );
    }
    
    //aggiorno campo denominazione
    UpgradeDenominazioneRTI();
  }
  
  
  //alert se azienda non trovata su onblur dal campo codicefiscale
  function MakeAlertAzienda() {
  
    var strNameCtl = this.name;
    var aInfo = strNameCtl.split('_');
    var strFullNameArea = aInfo[0] + '_' + aInfo[1];
    var nIndRrow = aInfo[2];
    
    //var strCF=this.value;
    
    //alert(strCF);
    var nPos=GetColumnPositionInGrid('RAGSOC',strFullNameArea);
    
    if ( nPos != -1 ){
      
      //alert( getObj(strFullNameArea + '_' + nIndRrow + '_' + nPos ).value ) ;
      
      if ( getObj(strFullNameArea + '_' + nIndRrow + '_' + nPos ).value == '' ) 
        alert(CNV ('../../' , 'codice fiscale azienda non esistente') );
    }
  }
  
  //setta le info di una azienda su una riga di una griglia
  function SetInfoAziendaRow( strFullNameArea, nIndRrow ,strresult ){
    
    
    var nPos;
    var ainfoAzi = strresult.split('#');
    
    var strRagSoc = ainfoAzi[0];
    nPos=GetColumnPositionInGrid('RAGSOC',strFullNameArea);
    if ( nPos != -1 ){
      getObj(strFullNameArea + '_' + nIndRrow + '_' + nPos ).value = strRagSoc ;
      getObj('cell_' + strFullNameArea + '_' + nIndRrow +'_'+ nPos).innerHTML = strRagSoc ;
    }  
    
    if (strFullNameArea == 'DOCUMENTAZIONE_ATIgriglia' && nIndRrow==1){
      var strCodicefiscale = ainfoAzi[4];
      nPos=GetColumnPositionInGrid('codicefiscale',strFullNameArea);
      if ( nPos != -1 ){
        getObj(strFullNameArea + '_' + nIndRrow + '_' + nPos ).value = strCodicefiscale ;
        
        //getObj('cell_' + strFullNameArea + '_' + nIndRrow +'_'+ nPos).innerHTML =  strCodicefiscale ;
      }  
    }
     
    nPos = -1;
    var strIndLeg = ainfoAzi[1];
    nPos=GetColumnPositionInGrid('INDIRIZZOLEG',strFullNameArea);
    if ( nPos != -1 ){
      getObj(strFullNameArea + '_' + nIndRrow + '_' + nPos ).value = strIndLeg ;
      getObj('cell_' + strFullNameArea + '_' + nIndRrow +'_'+ nPos).innerHTML = strIndLeg ;
    }  
    
   
    
    nPos = -1;
    var strLocLeg = ainfoAzi[2];
    nPos=GetColumnPositionInGrid('LOCALITALEG',strFullNameArea);
    if ( nPos != -1 ){
      getObj(strFullNameArea + '_' + nIndRrow + '_' + nPos ).value = strLocLeg ;
      getObj('cell_' + strFullNameArea + '_' + nIndRrow +'_'+ nPos).innerHTML = strLocLeg ;
    }  
    
    nPos = -1;
    var strProvLeg = ainfoAzi[3];
    nPos=GetColumnPositionInGrid('PROVINCIALEG',strFullNameArea);
    if ( nPos != -1 ){
      getObj(strFullNameArea + '_' + nIndRrow + '_' + nPos ).value = strProvLeg ;
      getObj('cell_' + strFullNameArea + '_' + nIndRrow +'_'+ nPos).innerHTML = strProvLeg ;
    }  
    
    nPos = -1;
    var strIdazi = ainfoAzi[5];
    nPos=GetColumnPositionInGrid('IdAzi',strFullNameArea);
    if ( nPos != -1 ){
      //alert(strIdazi);
      getObj(strFullNameArea + '_' + nIndRrow + '_' + nPos ).value = strIdazi ;
      //getObj('cell_' + strFullNameArea + '_' + nIndRrow +'_'+ nPos).innerHTML = strIdazi ;
    }  
    
    
    
    nPos = -1;
    nPos=GetColumnPositionInGrid('Ruolo_Impresa',strFullNameArea);
    var strRuolo='Mandataria';
    var strTechRuolo='1#~Mandataria';
    if (nIndRrow != 1){
      strRuolo='Mandante';
      strTechRuolo='2#~Mandante';
    }
    
    if (strresult == '#####'){
      strRuolo='';
      strTechRuolo='';
    }
      
    if ( nPos != -1 ){
      getObj(strFullNameArea + '_' + nIndRrow + '_' + nPos ).value = strTechRuolo ;
      getObj('cell_' + strFullNameArea + '_' + nIndRrow +'_'+ nPos).innerHTML = strRuolo ;
    }   
  }
  
  
  //controlla che questo codice fiscale non sia gi� presente
  function AziIsUnique ( strNameAreaCurrent , nRowCurrent , strCF ){
    
    var bIsUnique=true;
    
    //griglia RTI
    var nIndRrow;
    var strFullNameArea='DOCUMENTAZIONE_ATIgriglia';
    var nPosDesc=GetColumnPositionInGrid('codicefiscale',strFullNameArea);
    var objRow=getObj('NumProduct_'+ strFullNameArea);
    var nNumRow=Number(objRow.value);
    
    for ( nIndRrow=1; nIndRrow <= nNumRow; nIndRrow++){	
      
      if ( strFullNameArea != strNameAreaCurrent || ( strFullNameArea == strNameAreaCurrent && nIndRrow != nRowCurrent ) ){
          
          if (  getObj(strFullNameArea + '_' + nIndRrow + '_' + nPosDesc ).value.toUpperCase() == strCF.toUpperCase() ){
            alert( CNV ('../../' , 'azienda gia inserita nella griglia RTI') );
            bIsUnique=false;
            return bIsUnique;
          }
      }
    }    
    
    
    //griglia Consorzio
    strFullNameArea='DOCUMENTAZIONE_Consorziogriglia';
    nPosDesc=GetColumnPositionInGrid('codicefiscale',strFullNameArea);
    objRow=null;
    objRow=getObj('NumProduct_'+ strFullNameArea);
    nNumRow=Number(objRow.value);
    
    for ( nIndRrow=1; nIndRrow <= nNumRow; nIndRrow++){	
      
      if ( strFullNameArea != strNameAreaCurrent || ( strFullNameArea == strNameAreaCurrent && nIndRrow != nRowCurrent ) ){
          
          if (  getObj(strFullNameArea + '_' + nIndRrow + '_' + nPosDesc ).value.toUpperCase() == strCF.toUpperCase() ){
            alert( CNV ('../../' , 'azienda gia inserita nella griglia Consorzio') );
            bIsUnique=false;
            return bIsUnique;
          }
      }
    }
    
    
    //griglia Avvalimento
    strFullNameArea='DOCUMENTAZIONE_Avvalimentogriglia';
    nPosDesc=GetColumnPositionInGrid('codicefiscale',strFullNameArea);
    objRow=null;
    objRow=getObj('NumProduct_'+ strFullNameArea);
    nNumRow=Number(objRow.value);
    
    for ( nIndRrow=1; nIndRrow <= nNumRow; nIndRrow++){	
      
      if ( strFullNameArea != strNameAreaCurrent || ( strFullNameArea == strNameAreaCurrent && nIndRrow != nRowCurrent ) ){
          
          if (  getObj(strFullNameArea + '_' + nIndRrow + '_' + nPosDesc ).value.toUpperCase() == strCF.toUpperCase() ){
            alert( CNV ('../../' , 'azienda gia inserita nella griglia Avvalimento') );
            bIsUnique=false;
            return bIsUnique;
          }
      }
    }
    
    return bIsUnique;
  
  }
  
  //ricostruisce il campo denominazione
  function UpgradeDenominazioneRTI( ){
    
    var strTempValue;
    //aggiorno campo nascosto con la denominazione
    var objDenominazioneATI = getObj( 'elemento_DOCUMENTAZIONE_comuneATI_' + get_IdDztFromDztNome_AreaOfid('DOCUMENTAZIONE_comuneATI','DenominazioneATI') );
    objDenominazioneATI.value = '';
    
    var nIndRrow;
    var strAttrib;
    var iddztAttrib;
    var strFullNameArea;
    var objAttrib;
    var strvalue;
    var nPosDesc;
    var objRow;
    var nNumRow;
    var strvalueRTI;
    
    //controllo se partecipacomeRTI � settato
    strAttrib = "PartecipaFormaRTI";
    iddztAttrib = get_IdDztFromDztNome_AreaOfid( 'DOCUMENTAZIONE_comuneATI' , strAttrib );
    //objAttrib = getObj('elemento_DOCUMENTAZIONE_comuneATI_' + iddztAttrib ) ;
    objAttrib = eval ( 'document.new_document.elemento_DOCUMENTAZIONE_comuneATI_' + iddztAttrib );
    
    for (r=0; r < objAttrib.length; r++){
			if ( objAttrib[r].checked == true)
  			strvalue = objAttrib[r].value;
		}
    strvalueRTI = strvalue;
    
    if ( strvalue == '1'){
      
      strFullNameArea='DOCUMENTAZIONE_ATIgriglia';
      nPosDesc=GetColumnPositionInGrid('RAGSOC',strFullNameArea);
      objRow=getObj('NumProduct_'+ strFullNameArea);
      nNumRow=Number(objRow.value);
      
      if  ( nNumRow >0 && getObj(strFullNameArea + '_1_' + nPosDesc ).value != '' ){
        
        objDenominazioneATI.value = 'RTI ';
        
        for ( nIndRrow=1; nIndRrow <= nNumRow; nIndRrow++){	
          
          strTempValue = getObj(strFullNameArea + '_' + nIndRrow + '_' + nPosDesc ).value;
          
          if ( strTempValue != '' ){
            if (nIndRrow == 1)
              objDenominazioneATI.value =  objDenominazioneATI.value  + strTempValue ;
            else
              objDenominazioneATI.value =  objDenominazioneATI.value  + ' - ' + strTempValue ;
          }
          
        }    
      }
    }
    
    
    
    //controllo se InserisciEsecutriciLavori � settato
    strAttrib = "InserisciEsecutriciLavori";
    iddztAttrib = get_IdDztFromDztNome_AreaOfid( 'DOCUMENTAZIONE_ComuneConsorzio' , strAttrib );
    //objAttrib = getObj('elemento_DOCUMENTAZIONE_ComuneConsorzio_' + iddztAttrib ) ;
    objAttrib = eval ( 'document.new_document.elemento_DOCUMENTAZIONE_ComuneConsorzio_' + iddztAttrib );
    
    strvalue='0';
    for (r=0; r < objAttrib.length; r++){
			if ( objAttrib[r].checked == true)
  			strvalue = objAttrib[r].value;
		}
		
		if ( strvalue == '1'){
		  
      strFullNameArea='DOCUMENTAZIONE_Consorziogriglia';
      nPosDesc=GetColumnPositionInGrid('RAGSOC',strFullNameArea);
      objRow=null;
      objRow=getObj('NumProduct_'+ strFullNameArea);
      nNumRow=Number(objRow.value);
      
      if  ( nNumRow >0 && getObj(strFullNameArea + '_1_' + nPosDesc ).value != '' ){
        
        objDenominazioneATI.value = objDenominazioneATI.value + ' Esecutrice ';
        
        for ( nIndRrow=1; nIndRrow <= nNumRow; nIndRrow++){	
          
          strTempValue = getObj(strFullNameArea + '_' + nIndRrow + '_' + nPosDesc ).value;
          if ( strTempValue != '' ){
            if (nIndRrow == 1)
              objDenominazioneATI.value =  objDenominazioneATI.value  + strTempValue ;
            else
              objDenominazioneATI.value =  objDenominazioneATI.value  + ' - ' + strTempValue ;
          }
          
        }    
        
        //se non � settata RTI aggiungo all'inizio la ragsoc del consorzio
    		if ( strvalueRTI != '1'	){
    			nPosDesc=GetColumnPositionInGrid('RagSocConsorzio',strFullNameArea);
    			objDenominazioneATI.value = getObj(strFullNameArea + '_1_' + nPosDesc ).value + ' ' + objDenominazioneATI.value ;
    		}
    		
      }
    }
  }
  
  
 
  //NASCONDE IL CHECK DELLA PRIMA RIGA DELLA GRIGLIA RTI PER EVITARE LA CANCELLAZIONE DELLA MANDATARIA
  function HideCheck_FirstRow_GrigliaATI(){
    
    var objCheck = document.new_document.DOCUMENTAZIONE_ATIgriglia_seleziona_articoli ;
    
    if ( objCheck != null){
      if ( objCheck.length != undefined )
        setVisibility( objCheck[0] , 'none');
      else
        setVisibility( objCheck , 'none');
    }     
  }
  
  
  
  
  //per aggiungere righe ai consorzi/avvalimento
  function MySec_Dettagli_AddRow ( param ) {
  
    vet = param.split( '#' );

  	var w;
  	var h;
  	var Left;
  	var Top;
  	var altro;
  
  	if( vet.length < 3  )
      	{
  		w = screen.availWidth;
  		h = screen.availHeight;
  		Left=0;
  		Top=0;
  	}
  	else    
  	{
  		var d;
  		d = vet[2].split( ',' );
  		w = d[0];
  		h = d[1];
  		Left = (screen.availWidth-w)/2;
  		Top  = (screen.availHeight-h)/2;
  		
  		if( vet.length > 3 )
  		{
  			altro = vet[3];
  		}
  	}
	 
	 var strUrl = vet[0];
	 
	 //recupero idazi della griglia RTI
   var strIdaziRTI = GetAziRTI();
   
    //alert(strIdaziRTI);
   var strIdAziEsecutrici = GetEsecutriciConsorzio();
   //alert(strIdAziEsecutrici);
   if (strIdAziEsecutrici != '')
    strIdaziRTI = strIdaziRTI + ',' + strIdAziEsecutrici;
   
   var npos=strIdaziRTI.indexOf(',');
   
   if (npos == -1){
  	 
  	 var strDoc;
	   strDoc = getQSParamFromString(strUrl , 'DOCUMENT');
	   v = strDoc.split('.');
  	 
  	 //aggiungo direttamente l'azienda loggata
  	 var strAreaName = v[0];
     var iTypeMes = 55;
     var iSubTypeMes = getObj('iSubType').value;
     var IDMP_var = getObj('IdMarketPlace').value;
     var lIdMsg = getObj('lIdMsgPar').value;
     var lIdModello = v[3];
     var const_width=300;
  	 var const_height=150;
  			
     sinistra=(screen.width-const_width)/2;
		 alto=(screen.height-const_height)/2;
		 var Path='../../ctl_library/';
		
		 winnuovo=window.open('','nuovoconsorzio','toolbar=no,location=no,directories=no,status=<%=CONST_STATUS%>,menubar=no,resizable=yes,copyhistory=no,scrollbars=no,width='+const_width+',height='+const_height+',left='+sinistra+',top='+alto+',screenX='+sinistra+',screenY='+alto+'');
		 winnuovo.document.write('<link rel="stylesheet" href="' + Path + 'Themes/MsgBox.css" type="text/css">');
  	 winnuovo.document.write('<title>' + CNV ('../../' , 'Inserisci Riga' ) + '</title>');
  	 winnuovo.document.write('<table class="INFO_BOX" cellpadding=0 cellspacing=0><tr><td align=center class=caption>' + CNV ('../../' , 'Attenzione' ) + '</td></tr>');
  	 winnuovo.document.write('<tr><td class=elaborazione><img src="' + Path + 'images/grid/clessidra.gif" border="0" >' + CNV ('../../' , 'Elaborazione in corso...' ) + '</td></tr></table>');
		 
     document.new_document.action='FormInserisciArticolo.asp?strHideForm=1&strKeyCaptionForm=Inserisci Esecutrice&lIdModello=' + lIdModello + '&strAreaName='+strAreaName+'&IType='+iTypeMes+'&ISubType='+iSubTypeMes+'&IdMp='+IDMP_var+'&IdMsg=' + lIdMsg + '&strIdTidDominiEstesi=&IDROW_FROMADD=' + strIdaziRTI + '&TABLE_FROMADD=' + v[2] ;
     document.new_document.target='nuovoconsorzio';
		 document.new_document.submit();
      
   }else{
   
	  var  strUrl = strUrl + '&FilterHide= id in (' + strIdaziRTI + ')' ;
    return window.open(  strUrl ,vet[1],'toolbar=no,location=no,directories=no,status=no,menubar=no,resizable=yes,copyhistory=yes,scrollbars=yes,left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h + altro );
    
   }
    
  }
  
  
  //recupera la lista delle aziende della griglia RTI
  function GetAziRTI(){
    
    var strTempList='';
    var strTempValue='';
    
    var nIndRrow;
    var strFullNameArea='DOCUMENTAZIONE_ATIgriglia';
    var nPosDesc=GetColumnPositionInGrid('IdAzi',strFullNameArea);
    var objRow=getObj('NumProduct_'+ strFullNameArea);
    var nNumRow=Number(objRow.value);
    
    if  ( nNumRow >0 ){
      
      for ( nIndRrow=1; nIndRrow <= nNumRow; nIndRrow++){	
        
        strTempValue = getObj(strFullNameArea + '_' + nIndRrow + '_' + nPosDesc ).value;
        if ( strTempList == '' )
          strTempList =  strTempValue ;
        else
          strTempList =  strTempList + ',' + strTempValue ;
        
      }    
    }else{
      
      //recupero idazi azienda loggata
      var InfoAziLoggata = GetInfoAziendaLoggata();
      var ainfo=InfoAziLoggata.split('#');
      strTempList = ainfo[5];
    }
    
    return strTempList;
    
  }
 
  //recupera la lista delle aziende esecutrici nei CONSORZI
  function GetEsecutriciConsorzio(){
    
    var strTempList='';
    var strTempValue='';
    
    var nIndRrow;
    var strFullNameArea='DOCUMENTAZIONE_Consorziogriglia';
    var nPosDesc=GetColumnPositionInGrid('IdAzi',strFullNameArea);
    var objRow=getObj('NumProduct_'+ strFullNameArea);
    var nNumRow=Number(objRow.value);
    
    if  ( nNumRow >0 ){
      
      for ( nIndRrow=1; nIndRrow <= nNumRow; nIndRrow++){	
        
        strTempValue = getObj(strFullNameArea + '_' + nIndRrow + '_' + nPosDesc ).value;
        if ( strTempList == '' )
          strTempList =  strTempValue ;
        else
          strTempList =  strTempList + ',' + strTempValue ;
        
      }    
    }
    
    return strTempList;
    
  }
 
 //CONTROLLA CHE LE AZIENDE DI RIFERIMENTO DELLA GRIGLIA IN INPUT SIANO PRESENTI NELLA GRIGLIA RTI
 //OPPURE DEVE ESSERE SOLO L'AZIENDA LOGGATA
 function RiferimentiGridIsInRTI( strFullNameArea, strAttribRagSoc, strAttribIdAzi  ){
    
    var strListAziendeRTI= GetAziRTI() ;
    
    var strIdAziEsecutrici = GetEsecutriciConsorzio();

    if (strIdAziEsecutrici != '')
      strListAziendeRTI = strListAziendeRTI + ',' + strIdAziEsecutrici;
 
    strListAziendeRTI = ',' + strListAziendeRTI + ','
    
    //determino se esiste un raggruppamento RTI
    var bRTI=true;
    var strFullNameAreaRTI='DOCUMENTAZIONE_ATIgriglia';
    var objRowRTI=getObj('NumProduct_'+ strFullNameAreaRTI);
    var nNumRowRTI =Number(objRowRTI.value);
    
    if  ( nNumRowRTI == 0 )
      bRTI=false;
    
    
    var objRow = getObj('NumProduct_' + strFullNameArea );
    var nNumRow = Number(objRow.value);
    var nPosIdAzi = GetColumnPositionInGrid( strAttribIdAzi ,strFullNameArea );
    var nPosRagSoc = GetColumnPositionInGrid( strAttribRagSoc ,strFullNameArea );
    
    var strCurrIdAzi = '';
    
	  if ( nNumRow > 0 ) {
      
      var nIndRrow;
      for ( nIndRrow=1; nIndRrow<=nNumRow; nIndRrow++){	
        
        
        strCurrIdAzi = ',' + getObj(strFullNameArea + '_' + nIndRrow + '_' + nPosIdAzi ).value + ',';
        strCurrRagSoc =  getObj(strFullNameArea + '_' + nIndRrow + '_' + nPosRagSoc ).value ;
        
        if ( strListAziendeRTI.indexOf(strCurrIdAzi, 0) < 0 ){
          if (bRTI)
            alert( CNV ('../../' , 'attenzione azienda area ' + strFullNameArea ) + ' "' + strCurrRagSoc + '" ' + CNV ('../../' , 'non presente in rti' )   );
          else
            alert( CNV ('../../' , 'attenzione azienda area ' + strFullNameArea ) + ' "' + strCurrRagSoc + '" ' + CNV ('../../' , 'non azienda loggata' )   );
          
          return false;
          
        }
          
        
      }  
    }
    
    return true;
    
 }
 
 
//controlla se il fornitore collegato partecipa alla gara in un raggruppamento
function CheckFornitoreInRTI(){
 
  var strFascicolo = getObj('ProtocolBG').value ;
  
  //carico le info azienda loggata
  ajax = GetXMLHttpRequest(); 

  	if(ajax){
  		  
        ajax.open("GET", '../../ctl_library/functions/Check_CurrentUserInRTI.asp?SUBTYPE='+ getObj('iSubType').value  +'&FASCICOLO=' + escape(strFascicolo) , false);
  	 		 
  			ajax.send(null);
  			
  			if(ajax.readyState == 4) {
  			 
  				if(ajax.status == 200)
  				{
			      var strresult = ajax.responseText;
            //alert (strresult);
            if ( strresult == '')
              return 0;
         	}
  			}
  
  }
  	
  return 1;
  
 }
  
</script>