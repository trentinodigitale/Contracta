<script language="javascript">

  //dominio assoc. a CriterioAggiudicazioneGara
  var PDA_CriterioPrezzobasso	= '15531';
  var PDA_OffertaVantaggiosa	= '15532';
  var PDA_CriterioPrezzoAlto	= '16291';

  //dominio assoc. a StatoOfferta
  var Const_StatoOfferta_InAttesa	= 'inattesaricezione';
  var Const_StatoOfferta_Ricevuta	= 'ricevutaofferta';
  
  //dominio assoc. a TipoBando
  var Avviso = '1';
  var Bando  = '2';
  var Invito = '3';
  
  //dominio assoc. a ModalitadiPartecipazione
  var Modalita_Tradizionale = '16307';
  var Modalita_Telematica	  = '16308';
  
  //esegue azione sulla sezione destinatari indicata in strFullAreaName (sezione_area)
  function CustomActionOnCompanyDest( strFullAreaName ){
  
    //se si tratta di una tradizionale senza invito allora setto per 
    //le aziende inserite il campo StatoOfferta=ricevuta
    if ( getObj('TipoBando').value == Bando && getObj('ModalitadiPartecipazione').value == Modalita_Tradizionale ) {
    
      var nPos=GetColumnPositionInGrid('StatoOfferta',strFullAreaName );
      var strSezione = '';
      
      var aInfo = strFullAreaName.split('_');
      strSezione = aInfo[0];
      
      
      if ( nPos > 0){
        
        var nNumRow=Number( eval ( 'nNumCurrCompany_' + strSezione ) ) ;
        
        for ( nIndRrow=1; nIndRrow<=nNumRow; nIndRrow++){	
        
          //if ( getObj(strFullAreaName + '_' + nIndRrow + '_' + nPos ).value == Const_StatoOfferta_InAttesa  ){
            getObj(strFullAreaName + '_' + nIndRrow + '_' + nPos ).value = Const_StatoOfferta_Ricevuta ;
          //}
          
          //SetProperty ( getObj(strFullAreaName + '_' + nIndRrow + '_' + nPos ) , 'onFocus', 'Javascript:this.blur();' ) ;
          
        }
        
      }
    }
  }


  // rimappo la SEND per aggiungere un controllo sulla sezione destinatari in caso di 
  var oldSend=SEND;
  
  function NewSend(){
    
    var bEsito = false ; 
    bEsito = CheckCompanyDest_StatoArrivoProtocollo();
    
    if ( ! bEsito ){
      alert(CNVAJAX ('../../' , 'Nella sezione Elenco Ditte compilare correttamente i campi stato,data di arrivo e protocollo.' ));
      DrawLabel('1'); 
      FUNC_CompanyDes();
      return;
   }
    
    
    //chaimo la vecchia send
    oldSend('');
    
  }
  
  SEND = NewSend ;	
  
  
  //window.onload = SetOnChangeAttributi ;
  window.onload = InitTabulato ;
  
  function InitTabulato() {
   
    	//Nascondo vecchio campo incaricato a partire da una certa data
      HideIncaricatoAperto();
      
       //se CriterioAggiudicazioneGara=Offerta Economicamnete + vantagg. in CriterioValutazione ci sarà la voce "Con Coefficienti"
      if ( getObj('CriterioAggiudicazioneGara').value != PDA_OffertaVantaggiosa ){
          
        getObj('lblCoefficienteX').style.display='none';
        getObj('CoefficienteX').style.display='none';
        getObj('lblCriterioDiValutazione').style.display='none';
        getObj('CriterioDiValutazione').style.display='none';
        try {
          getObj('CoefficienteX_vis').style.display='none';
          getObj('CriterioDiValutazione_vis').style.display='none';   
       }catch(e){} 
      }     
      
   }
  
  //controllo sezione destinatari
  function CheckCompanyDest_StatoArrivoProtocollo(){
    
    
    //verifico se tradizionale senza invito
    var bTradSenzaInvito = false
    if ( getObj('TipoBando').value == Bando && getObj('ModalitadiPartecipazione').value == Modalita_Tradizionale ) 
      bTradSenzaInvito = true ;
    
    var strFullAreaName = 'CompanyDes_GridDest' ;
    
    var nPos=GetColumnPositionInGrid('StatoOfferta', strFullAreaName );
    var nPos1=GetColumnPositionInGrid('ReceivedDataMsg', strFullAreaName );
    var nPos2=GetColumnPositionInGrid('ProtocolloOfferta', strFullAreaName );
    
    var strSezione='CompanyDes' ;
    
    if ( nPos > 0){
      
      var nNumRow=Number( eval ( 'nNumCurrCompany_' + strSezione ) ) ;
      
      for ( nIndRrow=1; nIndRrow<=nNumRow; nIndRrow++){	
        
        if ( bTradSenzaInvito )  {
         
          if ( ( getObj(strFullAreaName + '_' + nIndRrow + '_' + nPos1 + '_vis' ).value == '' &&  getObj(strFullAreaName + '_' + nIndRrow + '_' + nPos2 ).value != '' ) ||  ( getObj(strFullAreaName + '_' + nIndRrow + '_' + nPos1 + '_vis' ).value != '' &&  getObj(strFullAreaName + '_' + nIndRrow + '_' + nPos2 ).value == '' ) )
            return false;
              
        }else{
          
          
          if ( getObj(strFullAreaName + '_' + nIndRrow + '_' + nPos ).value == Const_StatoOfferta_Ricevuta && ( getObj(strFullAreaName + '_' + nIndRrow + '_' + nPos1 + '_vis' ).value == '' || getObj(strFullAreaName + '_' + nIndRrow + '_' + nPos2 ).value == '' ) )
            return false;  
            
        }
        
        
      }
      
    }  
    
    return true;
  
  }
  
  
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

 
  //nasconde il campo incaricato a dominio aperto a partire da una certa data
  function HideIncaricatoAperto(){
    
    var strdata;
    try{
    
      nHide=0;
    
      try{
        strdata=getObj('ReceivedDataMsg')[0].value;
      }catch(e){
        strdata=getObj('ReceivedDataMsg').value;
      }
    
      //alert(strdata);
      if ( strdata > '2013-01-13T00:00:00')
        nHide=1;
        
      if (getObj('Stato').value == '0' || getObj('Stato').value == '1' || nHide==1){
        
        //nascondo vecchio incaricato della cover
        try{
          getObj('lblIncaricato').style.display='none';
          getObj('Incaricato').style.display='none';
        }catch(e){}
        
        try{
          getObj('lblIncaricato_vis').style.display='none';
          getObj('Incaricato_vis').style.display='none';
        }catch(e){}
        
        
        //nascondo vecchio RUP della sezione informazioni tecniche
        var objLabelRUP = getObj( 'spn_elemento_InformazioniTecniche_comune_' + get_IdDztFromDztNome_AreaOfid('InformazioniTecniche_comune','R.U.P') );
        objLabelRUP.style.display='none';
        var objRUP = getObj( 'elemento_InformazioniTecniche_comune_' + get_IdDztFromDztNome_AreaOfid('InformazioniTecniche_comune','R.U.P') );
        objRUP.style.display='none';
        
        
       
        
      }else{
        
        //nascondo il nuovo incaricato della cover
        try{
          getObj('lblUtenteIncaricato').style.display='none';
          getObj('UtenteIncaricato').style.display='none';
        }catch(e){}
        
        try{
          getObj('lblUtenteIncaricato').style.display='none';
          getObj('UtenteIncaricato_vis').style.display='none';
        }catch(e){}
        
       
        
        
      }
      
      if ( nHide == 0 ){
       //setto proceduragara a Aperta e lo blocco
        //getObj('ProceduraGara').value=ProceduraAperta
        //getObj('ProceduraGara').disabled=true;
      }
      
    }catch(e){
    }

    
    
  }

</script>