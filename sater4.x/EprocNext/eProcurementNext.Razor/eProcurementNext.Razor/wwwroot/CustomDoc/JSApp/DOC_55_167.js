
<script language="javascript"> 
//Versione=3&data=2013-04-10&Attivita=42115&Nominativo=Enrico

   var ModalitaTelematica = '16308' ;
   var ModalitaTradizionale = '16307' ;
   //dominio assoc. a CriterioAggiudicazioneGara
   var PDA_CriterioPrezzobasso	= '15531';
   var PDA_OffertaVantaggiosa	= '15532';
   var PDA_CriterioPrezzoAlto	= '16291';

   //dominio assoc. a  CriterioFormulazioneOfferte  
   var PDA_CriterioFormulazioneOffertePrezzo		 = '15536';
   var PDA_CriterioFormulazioneOffertePercentuale = '15537';
   
   //dominio assoc. a  OffAnomale
   var PDA_OffAnomaleAutomatica	= '16309';
   var PDA_OffAnomaleValutazione	= '16310';
  
   //dominio assoc. a  TipoProcedura
   var ProceduraAperta = '15476' ;
   var ProceduraRistretta = '15477' ;
   var ProceduraNegoziata = '15478' ;
   var ProceduraEconomia = '15475' ;
   var ProceduraRDP = '15479' ;
   var ProceduraRDI = '15480' ;
   
   //dominio assoc. a TipoBando
   var Avviso = '1';
   var Bando  = '2';
   var Invito = '3';
  
   //dominio assoc. a  FaseGara
   var FaseGara_Aggiudicata = '1' 
   var FaseGara_Qualifica = '4' ;
   var FaseGara_PresentazioneOfferte = '7' ;
   
   //dominio assoc. a RequestSignTemp
   var FirmaBusta_NO = '3';
   var FirmaBusta_SI = '4;TECNICA,ECONOMICA,DICHIARAZIONE';
   var FirmaBusta_SI_MICROLOTTI = '4;MicroLotti';
   var FirmaBusta_SI_CAUZIONE = '4;DOCUMENTAZIONE,MicroLotti';
   var FirmaBusta_SI_ECONOMICA = '4;ECONOMICA';
   
   //dominio associato a Divisione_lotti
   var Divisione_lotti_No = '0' ;
   var Divisione_lotti_LottiTrad = '1' ;
   var Divisione_lotti_Lotti = '2' ;
   
   //dominio tipoappalto
   var tipoappalto_Forniture = '15495';
   var tipoappalto_Servizi = '15494';
   var tipoappalto_LavoriPubblici = '15496';
   
   //conservo la lista completa delle opzioni
   var Old_CriterioAggiudicazioneGara_onchange ;
   var Old_CriterioFormulazioneOfferte_onchange ;
   var Old_Divisione_lotti_onchange ;
   var Old_ProceduraGara_onchange ;
   var Old_MicrolottoAllegato_onclick;
   
   
   var selValueCriterioValutazione ;
   var selValueTipoBando ;
   
   var ObjCriterioDiValutazioneCompleta ;
   var ObjTipoBandoCompleto ;
   var ObjEvidenzaPubblicaCompleto ;
   var ObjRichiestaQuesitoCompleto ;
   var ObjFaseGaraCompleto ;
   var ObjFirmaBustaCompleto ;
   
   var obbligDestinatari = 0;
       
   var oldSend;

   

  function NewSend(){
    
    var strDataApertura=getObj('DataAperturaOfferte').value;
    //Controllo che il campo data di apertura offerte (Data I Seduta) sulla testata sia maggiore o uguale del campo “presentare le offerte entro il”
    if ( ( getObj('ExpiryDate').value >=  getObj('DataAperturaOfferte').value ) || strDataApertura.length < 10 )
    {
    	//alert('La data \'Data I Seduta\' deve essere maggiore o uguale della data \'Presentare le offerte entro il\'');
    	alert ( CNVAJAX ('../../' , 'Data I Seduta deve essere maggiore scadenza' ) ) ;
    	DrawLabel('0'); 
    	FUNC_Cover1();
    	getObj('DataAperturaOfferte_vis').focus();
    	return;
    }
    
		//innesco i controlli base di tipo CANSEND del documento
		if  ( ! SENDBASE())
		  return;
    
    
    //CONTROLLO CHE NOW <= Rispondere Dal <= Rispondere Entro il
    /*
    if ( getObj('Rispondere_dal').value >= getObj('ExpiryDate').value ){
      alert(CNVAJAX ('../../' , 'Rispondere Dal deve essere minore uguale di data scadenza' ));
    	DrawLabel('0'); 
    	FUNC_Cover1();
    	getObj('Rispondere_dal_vis').focus();
    	return;
    }
    */
    
    //Se richiesta quesito =si CONTROLLO CHE NOW <= Termine Richiesta Quesiti <= Rispondere entro il 
    if ( getObj('RichiestaQuesito').value != '2'){
      var ObjDataNow = new Date();
      var strTecDataNow = zero( ObjDataNow.getFullYear(),4) + '-' + zero( (ObjDataNow.getMonth()+1),2) + '-' + zero(ObjDataNow.getDate(),2) + 'T' + zero(ObjDataNow.getHours(),2)  + ':' + zero(ObjDataNow.getMinutes(),2) +  ':' + zero(ObjDataNow.getSeconds(),2) ;
      //alert(strTecDataNow);
      if ( getObj('TermineRichiestaQuesiti').value > getObj('ExpiryDate').value || getObj('TermineRichiestaQuesiti').value < strTecDataNow ) {
        alert(CNVAJAX ('../../' , 'Termine Richiesta Quesiti maggiore di now e minore uguale data scadenza' ));
      	DrawLabel('0'); 
      	FUNC_Cover1();
      	getObj('TermineRichiestaQuesiti_vis').focus();
      	return;
      }
    }  
		var bret;
      
    //criterio di aggiudicazione = AL PREZZO + BASSO  e criterio di formulazione offerta= importo 
    //allora importo a base d'asta è obbligatorio
    var CriterioAggiudicazioneGara = getObj('CriterioAggiudicazioneGara').value;
    //alert (CriterioAggiudicazioneGara);
    var CriterioFormulazioneOfferte = getObj('CriterioFormulazioneOfferte').value;
    
    
    //controllo che importo appalto obbligatorio
    var ImportoAppalto=getObj('ImportoBaseAsta').value;
    if ( ImportoAppalto == '' || parseFloat ( ImportoAppalto )  <= '0'){
      
      alert( CNVAJAX ('../../' , 'Il campo ImportoAppalto obbligatorio.' ) );
      getObj('Vis_ImportoBaseAsta').focus();
      return;
      
    }
    
    
      
    //se criterio=OFFERTA ECONOMICAMENTE + VANTAGGIOSA verificare che l'attributo
	  //OffAnomale=valutazione
	  try{
		  var OffAnomale = getObj('OffAnomale').value;
		  if ( CriterioAggiudicazioneGara == PDA_OffertaVantaggiosa && getObj('CalcoloAnomalia').value != '0' && OffAnomale != PDA_OffAnomaleValutazione ) {
          
          alert(CNVAJAX ('../../' , 'Il campo Offerte anomale deve essere settato a Valutazione.' ));
          DrawLabel('0'); 
  	      FUNC_Cover1();
          getObj('OffAnomale').focus();
          return;    
          
		  }
    }catch(e){
    }
      
    //SE SI TRATTA DI UNA RETTIFICA CONTROLLO CHE HO INSERITO ALLEGATI NEGLI AVIVSI DI RETTIFICA
    var Rettifica;
    var NumProduct_BANDO_rettifiche;
    Rettifica='no';
    NumProduct_BANDO_rettifiche=0;
    try{ 
      Rettifica = getObj('Rettifica').value;
      NumProduct_BANDO_rettifiche = getObj('NumProduct_BANDO_rettifiche').value ;
    }
    catch(e){
    }
    
    if ( Rettifica == 'si' && NumProduct_BANDO_rettifiche == 0 ){
      alert(CNVAJAX ('../../' , 'Inserire un avviso di rettifica' ));
      DrawLabel('1'); 
      FUNC_BANDO();
      return; 
    }
    
    //IN CASO DI RETTIFICA CONTROLLO CHE LE RIGHE DEGLI AVVISI DI RETTIFICA SONO VALORIZZATE
    var strFullNameArea = 'BANDO_rettifiche';
    if ( Rettifica == 'si' && NumProduct_BANDO_rettifiche > 0 ){
      
      var nPosDesc=GetColumnPositionInGrid('DescrAttach',strFullNameArea);
      var nPosAttach=GetColumnPositionInGrid('Attach',strFullNameArea);
          
      for ( nIndRrow=1; nIndRrow <= NumProduct_BANDO_rettifiche; nIndRrow++ ){	
     
        if ( getObj(strFullNameArea + '_' + nIndRrow + '_' + nPosDesc ).value == '' ){
            
            DrawLabel('1'); 
            FUNC_BANDO();
            alert(CNVAJAX ('../../' , 'Valorizzare Descrizione Avviso di Rettifica' ));
            getObj(strFullNameArea + '_' + nIndRrow + '_' + nPosDesc ).focus();
            return; 
        }
        if ( getObj(strFullNameArea + '_' + nIndRrow + '_' + nPosAttach ).value == '' ){
            
            DrawLabel('1'); 
            FUNC_BANDO();
            alert(CNVAJAX ('../../' , 'Valorizzare Allegato Avviso di Rettifica' ));
            getObj( 'Button_' + strFullNameArea + '_' + nIndRrow + '_' + nPosAttach ).focus();
              
            return; 
        }
      }
    }
    
    
    //SOLO SE PROCEDURA APERTA/INVITO  
    if ( getObj('ProceduraGara').value == ProceduraAperta || getObj('TipoBando').value == Invito ){
      
      //SE SI TRATTA DI PROCEDURA TELEMATICA E NON A MICROLOTTI
      if ( getObj('ModalitadiPartecipazione').value == ModalitaTelematica &&  getObj('Divisione_lotti').value == Divisione_lotti_No){
        
        
        
        
        //CONTROLLO IMPORTO BASE ASTA OBBLIG POSITIVO
        var strImpBaseAsta = getObj('ImportoBaseAsta2').value ;
        var ValImpBaseAsta = parseFloat ( strImpBaseAsta ) ;
        if ( strImpBaseAsta == '' || ValImpBaseAsta <= 0 ){
          
          alert(CNV ('../../' , 'Il campo Importo Base Asta e obbligatorio.' ));
        	DrawLabel('1'); 
          FUNC_Cover1();
          getObj('Vis_ImportoBaseAsta2').focus();
        	return;
        
        }
        
        //CONTROLLO CHE IMPORTO BASE ASTA UGUALE A QUELLO INSERITO NELLA SEZIONE "INF. TECNICHE"
        bret = true;
        bret = CheckImportoBaseAstaInfTecniche();
        if ( ! bret){
        
          alert(CNV ('../../' , 'Importo base asta non coincide con importo soggetto a ribasso' ));
          DrawLabel('2'); 
          FUNC_InformazioniTecniche();
          return;
        }

        
        //CONTROLLO CHE FORMULA ECONOMICA SI VALORIZZATA
        var iddztFormulaValutazione = get_IdDztFromDztNome_AreaOfid('CRITERI_comune','EconomicExpression');
        var objFormulaEcono = getObj('elemento_CRITERI_comune_' + iddztFormulaValutazione);
        var objbuttonFormula = getObj('btn_elemento_CRITERI_comune_' + iddztFormulaValutazione);
        if ( objFormulaEcono.value == '' )
        {
        	alert(CNV ('../../' , 'La Formula Economica deve essere valorizzata' ));
        	DrawLabel('11'); 
          FUNC_CRITERI();
          objbuttonFormula.focus();
        	return;
        }
        
        //CONTROLLO CHE PUNTEGGIO ECONOMICO SIA VALORIZZATO POSITIVO
        var iddztValutazione = get_IdDztFromDztNome_AreaOfid('CRITERI_comune','Punteggioeconomico');		
        var MAXPuntECO=0;
        var objEcono = getObj('elemento_CRITERI_comune_' + iddztValutazione ) ;
        MAXPuntECO = parseFloat ( objEcono.value ) ;
        if ( objEcono.value == '' || MAXPuntECO <= 0)
      	{
      		alert(CNV ('../../' , 'La valutazione economica deve essere maggiore di 0' ));
      		DrawLabel('11'); 
          FUNC_CRITERI();
          getObj('Vis_elemento_CRITERI_comune_' + iddztValutazione ).focus();
      		return;
      	}
      	
      	
      	//CONTROLLO CHE IMPORTO BASA ASTA IN TESTATA SIA UGUALE SOMMA IMPORTI DELLA BUSTA ECONOMICA
        var nret;
        nret = 0;
        nret = CheckImportoBaseAsta();
      	if ( nret == -1 ){
      
          alert(CNVAJAX ('../../' , 'Importo base asta in testata non coincide con quelli della busta economica' ));
          DrawLabel('8'); 
    	    FUNC_ECONOMICA();
    	    return;
        }
        
        if ( nret == -2 ){
      
          alert(CNVAJAX ('../../' , 'Valorizzare gli importi nella busta economica' ));
          DrawLabel('8'); 
    	    FUNC_ECONOMICA();
    	    return;
        }
          
          
        //SE CRITERIOAGGIUDICAZIONEGARA=OFFERTA ECONOMIC. PIU' VANTAGGIOSA CONTROLLO
        //I CRITERI A QUIZ SE PRESENTI e CHE LA SOMMA DEI MAX PUNTEGGIO ECONOMICO e TECNICO SIA 100  
        if ( CriterioAggiudicazioneGara == PDA_OffertaVantaggiosa ) {
            
          //CONTROLLO CHE SONO VALORIZZATI EVENTUALI CRITERI A QUIZ
          if ( ! CheckCriteriQuizCompiled() ){
            alert(CNVAJAX ('../../' , 'Compilare i criteri quiz nella busta tecnica' ));
            DrawLabel('7'); 
  	        FUNC_TECNICA();
  	        return;
          }
          
          //FACCIO LA SOMMA DEI PUNTEGGI
          var strNameControl='CRITERI_griglia' ;
          var nPos=GetColumnPositionInGrid('Score',strNameControl);
          var MAXPuntTEC=0;
          if ( nPos > 0){
            
            var objRow=getObj('NumProduct_'+ strNameControl);
	          var nNumRow=Number(objRow.value);
            //alert(nNumRow);
            for ( nIndRrow=1; nIndRrow<=nNumRow; nIndRrow++){	
                if (getObj(strNameControl + '_' + nIndRrow + '_' + nPos ).value != '')
                  MAXPuntTEC = parseFloat(MAXPuntTEC) + parseFloat(getObj(strNameControl + '_' + nIndRrow + '_' + nPos ).value) ;
            
            }
          }
          
          if ( MAXPuntTEC + MAXPuntECO != 100 ){
            
            alert(CNVAJAX ('../../' , 'La somma del MAX Punteggio Economico e del MAX Punteggio Tecnico deve essere 100.' ));
            DrawLabel('11'); 
            FUNC_CRITERI();
            return;
          }
          
        }
        
        //verifico che se presenti gli attributi CarQuantitaDaOrdinare,Peso,Coefficiente
        //siano maggiori di 0
        var strAttribCheck = '';
        strAttribCheck = CheckAttributiBustaEconomica();
        if ( strAttribCheck != '' ){
          alert(CNVAJAX ('../../' , strAttribCheck + ' deve essere maggiore di 0' ));
          DrawLabel('8'); 
    	    FUNC_ECONOMICA();
    	    return;
        }
          
      }
    }
    
    //se devo inserire i destinatari lo controllo dando un messaggio 
    //if ( getObj( 'CompanyDes_Hide' ).value == '0' && nNumCurrCompany_CompanyDes == 0 ){
      
    //  alert(CNVAJAX ('../../' , 'Inserire almeno un Destinatario' ));
    //  DrawLabel('4'); 
    //  FUNC_CompanyDes();
    //  return;
      
    //}  
      
      
    //SE MICROLOTTI CONTROLLO CHE ABBIA SCELTO UN MODELLO E CHE LO ABBIA ALLEGATO.
    if ( getObj( 'Divisione_lotti' ).value == '2'  ){
    
      //controllo sia selezionato un modello
      var objListaModelli = getObj( 'elemento_MicroLotti_MicrolottoComune_' + get_IdDztFromDztNome_AreaOfid('MicroLotti_MicrolottoComune','ListaModelliMicrolotti') );
    
      if ( objListaModelli.value == '') {
        alert( CNVAJAX ('../../' , 'Selezionare un modello di microlotto' ) );
        DrawLabel('5'); 
        FUNC_MicroLotti();
        getObj( 'elemento_MicroLotti_MicrolottoComune_' + get_IdDztFromDztNome_AreaOfid('MicroLotti_MicrolottoComune','ListaModelliMicrolotti') ).focus();
        return;
      }  
      
      //controllo sia allegato un modello
      var objMicrolottoAllegato = getObj( 'elemento_MicroLotti_MicrolottoComune_' + get_IdDztFromDztNome_AreaOfid('MicroLotti_MicrolottoComune','MicrolottoAllegato') );
      if ( objMicrolottoAllegato.value == '') {
        alert( CNVAJAX ('../../' , 'Allegare microlotto' ) );
        DrawLabel('5'); 
        FUNC_MicroLotti();
        getObj( 'Button_elemento_MicroLotti_MicrolottoComune_' + get_IdDztFromDztNome_AreaOfid('MicroLotti_MicrolottoComune','MicrolottoAllegato') ).focus();
        return;
      }
    }  
      
       
	  oldSend('SEND,APPROVAZIONE');
	  
  }	

   //SEND = NewSend ;	
   
   
  
   
   //window.onload = SetOnChangeAttributi ;
   window.onload = InitBando ;
   
   function InitBando() {
   
    	//controllo se rimappare la SEND in funzione del ciclo di approvazione	
    	if (getObj('AdvancedState').value!='4' && getObj('Stato').value!='2' )
    	{
    	 oldSend=ExecDocProcess;
    		ExecDocProcess = NewSend;
    	}
		  
		  SetOnChangeAttributi();
      
      //Nascondo la colonna Valore Offerta della griglia Busta Economica
      HideValoreOffertoBustaEconomica();
      
      //Nascondo vecchio campo incaricato a partire da una certa data
      HideIncaricatoAperto();
      
      //Nascondo attributi a prescindere
      HideAttrib();
	  
	    //nasconde il campo allegato nella busta economica 
	    HideAllegatoBustaEconomica();
      
      //in caso di bando REVOCATO controlla se disabilitare i comandi PDA/PREQUALIFICA 
      if ( getObj('AdvancedState').value == '7' )
        DisablePDA_Prequalifica();
      
      //gestione sezione destinatari
      HandleSezioneDestinatari();
      
   }
   
   function SetCriterioValutazione(){
      
      try{
        Old_CriterioAggiudicazioneGara_onchange();
        Old_CriterioFormulazioneOfferte_onchange();
      }catch(e){
        
      }
      //se CriterioAggiudicazioneGara=Offerta Economicamnete + vantagg. in CriterioValutazione ci sarà la voce "Con Coefficienti"
      if ( getObj('CriterioAggiudicazioneGara').value != PDA_OffertaVantaggiosa ){
      
           
           
           rimuovivoce ( 'CriterioDiValutazione' , 'coefficienti' );
           getObj('lblCoefficienteX').style.display='none';
           getObj('CoefficienteX').style.display='none';
           getObj('lblCriterioDiValutazione').style.display='none';
           getObj('CriterioDiValutazione').style.display='none';
           
           //setto una formula predefinita
           SetFormula() ;
           
      }else{
           
           //setto offanomale a valutazione
           getObj('OffAnomale').value = PDA_OffAnomaleValutazione ;
           
           aggiungivoce ( ObjCriterioDiValutazioneCompleta , 'CriterioDiValutazione' , 'coefficienti' );
           getObj('lblCoefficienteX').style.display='inline';
           getObj('CoefficienteX').style.display='inline';
           getObj('lblCriterioDiValutazione').style.display='inline';
           getObj('CriterioDiValutazione').style.display='inline';
      }
      //se CriterioFormulazioneEconomica=Prezzo ci sarà  la voce "Miglior Prezzo"
      
      //setto offanomale secondo tipobando
      SetAttributiFromTipoAppalto();
      
      if ( getObj('CriterioFormulazioneOfferte').value == PDA_CriterioFormulazioneOffertePrezzo )
          //aggiungivoce ( 'migliorprezzo' );
          aggiungivoce ( ObjCriterioDiValutazioneCompleta , 'CriterioDiValutazione' , 'migliorprezzo' );
      else
           //rimuovivoce ( 'migliorprezzo' );
           rimuovivoce ( 'CriterioDiValutazione' , 'migliorprezzo' );
      
      // se CriterioFormulazioneEconomica=Percentuale ci sarà  la voce "Miglior Percentuale di Sconto"	
      if ( getObj('CriterioFormulazioneOfferte').value == PDA_CriterioFormulazioneOffertePercentuale ){
          //aggiungivoce ( 'migliorsconto' );
          
          aggiungivoce ( ObjCriterioDiValutazioneCompleta , 'CriterioDiValutazione' , 'migliorsconto' );
          
      }else{
          //rimuovivoce ( 'migliorsconto' );
          
          rimuovivoce ( 'CriterioDiValutazione' , 'migliorsconto' );
          
      }
	  if ( getObj('CriterioAggiudicazioneGara').value == PDA_CriterioPrezzobasso) 
	  {
		//svuoto la griglia
         ResetGridRTI ( 'CRITERI_griglia' );	
		//nasconde griglia e toolbar
		try { setVisibility(getObj('command_CRITERI_griglia'),'none');}catch(e){}			
		setVisibility(getObj('CRITERI_griglia'),'none');
			
	  }
	  else
	  {
		//rende visibile toolbar e griglia
		try { setVisibility(getObj('command_CRITERI_griglia'),''); }catch(e){}	
		setVisibility(getObj('CRITERI_griglia'),'');
	  }
      
      //nascondo/visualizzo le buste infunzione di tipobando
      HideBusteFromProgeduraGara_TipoBando();
            
   }
   
   
   function SetOnChangeAttributi(){
      
      
      //se si tratta di un nuovo bando elimino la voce LOTTI TRADIZIONALI dall'attributo Divisione_Lotti
      try{
        rimuovivoce ( 'Divisione_lotti' , Divisione_lotti_LottiTrad  );
      }catch(e){}
      
      
      if ( getObj('Stato').value == '0' || ( getObj('Stato').value == '1' && getObj('AdvancedState').value != '4' && getObj('AdvancedState').value != '5' ) ){
       
        //faccio la copia della combo CriterioDiValutazione
        ObjCriterioDiValutazioneCompleta = CopiaListaCompleta( 'CriterioDiValutazione' );
        
        //conservo il valore selezionato della combo CriterioDiValutazione
        selValueCriterioValutazione = '' ;
        if ( getObj('Stato').value == '1' )
          selValueCriterioValutazione = getObj('CriterioDiValutazione').value ;
        
        
        
        //svuoto combo CriterioDiValutazione
        svuota( 'CriterioDiValutazione' , selValueCriterioValutazione );
        
        aggiungivoce ( ObjCriterioDiValutazioneCompleta , 'CriterioDiValutazione' , 'altro' );
        
        
        Old_CriterioAggiudicazioneGara_onchange = getObj('CriterioAggiudicazioneGara').onchange;      
        getObj('CriterioAggiudicazioneGara').onchange = SetCriterioValutazione ;
        
        Old_CriterioFormulazioneOfferte_onchange = getObj('CriterioFormulazioneOfferte').onchange;
        getObj('CriterioFormulazioneOfferte').onchange = SetCriterioValutazione ;
        
        SetCriterioValutazione();
        
        
        
        //associo azione onchange per preimpostare la formula se CriterioDiValutazione  <> altro
        getObj('CriterioDiValutazione').onchange = SetFormula ;
      
        
        
        //associo azione onchange per preimpostare il coefficiente giusto se la formula è allegatop
        getObj('CoefficienteX').onchange = SetFormula ;
        
        
        
        if ( ( getObj('Stato').value == '0' && ( getObj('lIdMsgSourcePar').value== '' || getObj('lIdMsgSourcePar').value== '-1' ) )  || ( getObj('Stato').value == '1' && getObj('ProceduraGara').value == ProceduraAperta &&   getObj('TipoBando').value == Avviso ) ){
          
          nhideDestinatari=1;
          getObj('ProceduraGara').selectedIndex = -1 ;
          getObj('TipoBando').selectedIndex = -1 ;
          getObj('EvidenzaPubblica').selectedIndex = -1 ;
          getObj('RichiestaQuesito').selectedIndex = -1 ;
          getObj('DirezioneProponente').selectedIndex = -1 ;
        }
        
        
        
        //faccio la copia della combo TipoBando
        try{
          ObjTipoBandoCompleto = CopiaListaCompleta( 'TipoBando' );
          
          //conservo il valore di TipoBando
          selValueTipoBando = '' ;
          if ( getObj('Stato').value == '1' )
            selValueTipoBando = SelectedListValue ('TipoBando');
          
          //svuoto combo TipoBando
          svuota( 'TipoBando' , selValueTipoBando );
          
          //Setto TipoBando e Caption del documento
          //SetTipoBandoSenzaSvuotare();
        }catch(e){
          
        }
        
        
        //faccio la copia della combo EvidenzaPubblica
        try{
          ObjEvidenzaPubblicaCompleto = CopiaListaCompleta( 'EvidenzaPubblica' );
          //conservo il valore di EvidenzaPubblica
          selValueEvidenzaPubblica = '' ;
          if ( getObj('Stato').value == '1' )
            selValueEvidenzaPubblica = SelectedListValue ('EvidenzaPubblica');
          //svuoto combo EvidenzaPubblica
          svuota( 'EvidenzaPubblica' , selValueEvidenzaPubblica );
        }catch(e){
          
        }
        
        //faccio la copia della combo RichiestaQuesito
        try{
          ObjRichiestaQuesitoCompleto = CopiaListaCompleta( 'RichiestaQuesito' );
          //conservo il valore di RichiestaQuesito
          selValueRichiestaQuesito = '' ;
          if ( getObj('Stato').value == '1' )
            selValueRichiestaQuesito = SelectedListValue ('RichiestaQuesito');
          //svuoto combo RichiestaQuesito
          svuota( 'RichiestaQuesito' , selValueRichiestaQuesito );
        }catch(e){
          
        }
        
        try{
          //faccio la copia della combo FaseGara
          ObjFaseGaraCompleto = CopiaListaCompleta( 'FaseGara' );
          //conservo il valore di FaseGara
          selValueFaseGara = '' ;
          if ( getObj('Stato').value == '1' )
            selValueFaseGara = SelectedListValue ('FaseGara');
          
          //se il doc è salvato il valore "Aggiudicata" non è ammesso come FaseGara
		      if ( getObj('Stato').value == '1'  && selValueFaseGara == FaseGara_Aggiudicata )
			       selValueFaseGara = '';
			       
          //svuoto combo FaseGara
          svuota( 'FaseGara' , selValueFaseGara ); 
        }catch(e){
          
        }
        
        
        Old_ProceduraGara_onchange = getObj('ProceduraGara').onchange;      
        getObj('ProceduraGara').onchange = SetTipoBando ;
        
        Old_TipoBando_onchange = getObj('TipoBando').onchange;      
        getObj('TipoBando').onchange = SetAttributiFromTipoBando ;
        
        
        
          
        //setto TipoBando e Caption
        SetTipoBando( 0 );
        
        
        //cambio on_chane di Divisione_lotti
        Old_Divisione_lotti_onchange = getObj('Divisione_lotti').onchange;      
        getObj('Divisione_lotti').onchange = SetInfoLotti ;
        
        //se nuovo  obbligo a selezionarlo
        if ( getObj('Stato').value == '0' ) 
           getObj('Divisione_lotti').selectedIndex = -1 ;
        
        
        
        HandleCampiMicroLotti();
        
        
        //faccio la copia della combo FaseGara
        ObjFirmaBustaCompleto = CopiaListaCompleta( 'RequestSignTemp' );
        //getObj('RequestSignTemp').selectedIndex = -1 ;
        
        
        //associo onchange all'attributo ClausolaFideiussoria per settare correttamente FirmaBusta
        getObj('ClausolaFideiussoria').onchange = SetFirmaBusta ;        
        
        
        //NEI CRITERI disabilito i criteri a QUIZ
        DisableCriteriQuiz();
        
        
        
        //NELLA BUSTA TECNICA SETTO onchange sulla descrizione su tutte le righe
        SetOnChangeDescTecnicaForQuiz();
        
        
        
        //se nuovo obbligo a selezionare il nuovo campo (se presente) a dominio UtenteIncaricato
        try{
          if ( getObj('Stato').value == '0' && getObj('ProtocolBG').value == '' ) 
            getObj('UtenteIncaricato').selectedIndex = -1 ;
        }catch(e){
        }
        
        //se nuovo se orario di TermineRichiestaQuesiti è 00:00:00 lo setto con 12:00:00
        if ( getObj('TermineRichiestaQuesiti_hh').value == '00' )
          getObj('TermineRichiestaQuesiti_hh').value = '12';
        
        
        //setto onchange sul campo tipoappalto
        Old_tipoappalto_onchange = getObj('tipoappalto').onchange;      
        getObj('tipoappalto').onchange = SetAttributiFromTipoAppalto ;
        
        
        
      }else {
        
           
          var KEYML;
          //setto la caption corretta 
          if ( getObj('TipoBando').value == '' )
            KEYML = 'message_55_167' ;
          else
            KEYML = 'message_55_167_' + getObj('ProceduraGara').value + '_' + getObj('TipoBando').value ;
          
          getObj('CaptionDocument').innerHTML = CNVAJAX ('../../' , KEYML ) ; 
          
          //nascondo coefficiente x
          if ( getObj('CriterioAggiudicazioneGara').value != PDA_OffertaVantaggiosa ){
             getObj('lblCoefficienteX').style.display='none';
             getObj('CoefficienteX_vis').style.display='none';
             getObj('lblCriterioDiValutazione').style.display='none';
             getObj('CriterioDiValutazione_vis').style.display='none';
          }
          
          //se il criterio è <> coefficienti nascondo CoefficienteX
          if ( getObj('CriterioDiValutazione').value != 'coefficienti' ){
            getObj('lblCoefficienteX').style.display='none'; 
            getObj('CoefficienteX_vis').style.display='none';
          } 
          
          if ( getObj('CriterioDiValutazione').value == '' ){
            getObj('lblCriterioDiValutazione').style.display='none';
            getObj('CriterioDiValutazione_vis').style.display='none';
          }
          
          //nascondo buste secondo tipoprocedura
          HideBusteFromProgeduraGara_TipoBando();
          
        
      }
      //nascondo grligliacriteri se criterioaggiudicazionegara al prezzo più basso e non editabile
		 if ( getObj('CriterioAggiudicazioneGara').value == PDA_CriterioPrezzobasso) 
		  {
			 //setStyleProp(getObj('CRITERI_griglia'),'visibility','hidden');
			 setVisibility(getObj('CRITERI_griglia'),'none');
		  }
      
      //imposto i campi coinvolti dalla GESTIONE LOTTI      
      SetInfoLotti();
      
      //nascondo il campo OffAnomale se il Calcolo Anomalia non è richiesto 
	    Old_CalcoloAnomalia_onchange = getObj('CalcoloAnomalia').onchange ;
	    getObj('CalcoloAnomalia').onchange = onChangeAnomalia ;
	    onChangeAnomalia();
      
   }
   
   

  
  
  
	
	//setta la formula secondo i criteri selezionati
	function SetFormula(){
    //elemento_CRITERI_comune_1084
    //recupero iddzt di EconomicExpression che contiene la formula
    var ListAttrib = getObj('ListAttrib_CRITERI_comune').value;
    var ainfo = ListAttrib.split('#');
    var ainfo1 ;
    var InfoAttrib ;
    var iddztEconomicExpression;
    var iddztPunteggioEconomico;
    
    
    
    
    for ( i=0; i < ainfo.length; i++ ){
				
				InfoAttrib=ainfo[i];
				
				ainfo1=ainfo[i].split(';');
				
				if (ainfo1[0] == 'EconomicExpression'){
					iddztEconomicExpression = ainfo1[1];
				}
				
				if (ainfo1[0] == 'Punteggioeconomico'){
					iddztPunteggioEconomico = ainfo1[1];
			  }
    } 
    
    getObj('Vis_elemento_CRITERI_comune_' + iddztPunteggioEconomico ).value = '' ;
    getObj('elemento_CRITERI_comune_' + iddztPunteggioEconomico ).value = '' ;
    
     //se CriterioAggiudicazioneGara = prezzo + basso setto la formula punteggio*ValoreOfferta e Putenggio=1
    if ( getObj('CriterioAggiudicazioneGara').value == PDA_CriterioPrezzobasso ){
     
      result = 'Punteggio*Valore Offerta';
      
      getObj('elemento_CRITERI_comune_' + iddztEconomicExpression ).value = result + '@@@Round,2';
      getObj('label_elemento_CRITERI_comune_' + iddztEconomicExpression ).innerHTML = result ;
      
      getObj('Vis_elemento_CRITERI_comune_' + iddztPunteggioEconomico ).value = 1 ;
      getObj('elemento_CRITERI_comune_' + iddztPunteggioEconomico ).value = 1 ;
      
      return;
    }
    
    var codice = getObj('CriterioDiValutazione').value ;
    
    if ( codice != 'altro' ) {
    
      var result = '';
      
      ajax = GetXMLHttpRequest(); 
  
  	  if(ajax){
      		
  		    ajax.open("GET", '../../ctl_library/functions/GetFormula.asp?CODICE=' + escape( codice ) , false);
  			 
  		    ajax.send(null);
  		    if(ajax.readyState == 4) {
  			    if(ajax.status == 200)
  			    {
  				    result =  ajax.responseText;
  				    
  			    }
  		    }
  	  }
     
      //nel caso di coefficienti sostituisco nella formula la X
      if ( codice == 'coefficienti' ){
          result = ReplaceExtended( result , 'X' , getObj('CoefficienteX').value ) ;
      }
            
      getObj('elemento_CRITERI_comune_' + iddztEconomicExpression ).value = result ;
      getObj('label_elemento_CRITERI_comune_' + iddztEconomicExpression ).innerHTML = result ;
      //disabilito la gestione della formula nella busta criteri
      //getObj('btn_elemento_CRITERI_comune_' + iddztEconomicExpression ).style.display='none';
      
    }else {
   
      getObj('elemento_CRITERI_comune_' + iddztEconomicExpression ).value = '' ;
      getObj('label_elemento_CRITERI_comune_' + iddztEconomicExpression ).innerHTML = '' ;
      //getObj('btn_elemento_CRITERI_comune_' + iddztEconomicExpression ).style.display='';
    }
    
    
    //se il criterio è <> coefficienti nascondo CoefficienteX
    if ( codice != 'coefficienti' ){
      getObj('lblCoefficienteX').style.display='none'; 
      getObj('CoefficienteX').style.display='none';
    } else{
      getObj('lblCoefficienteX').style.display=''; 
      getObj('CoefficienteX').style.display='';
    }
    
    
  }
  
  
  
   
  //setta TipoBando e caption del documento
  function SetTipoBando( nsvuotacombo ){
    
    try{
      Old_ProceduraGara_onchange();
    }catch(e){
    }

    var strRettifica = 'no';  
    try{ strRettifica = getObj('Rettifica').value; }catch(e){}
    
    try{
      
      if (nsvuotacombo != 0)
         svuota( 'TipoBando' , '' );
      
      //setta TipoBando
      if  ( getObj('ProceduraGara').value == ProceduraAperta ) {
        aggiungivoce ( ObjTipoBandoCompleto , 'TipoBando' , Bando );
      }
      
      if  ( getObj('ProceduraGara').value == ProceduraRistretta ) {
        if  ( getObj('ProtocolBG').value == '' ){
           aggiungivoce ( ObjTipoBandoCompleto , 'TipoBando' , Bando );
        }else{
          if ( strRettifica != 'si' ){
            rimuovivoce ( 'TipoBando' , Avviso ); 
            aggiungivoce ( ObjTipoBandoCompleto , 'TipoBando' , Invito );
          }
        }
      }
      
      if  ( getObj('ProceduraGara').value == ProceduraNegoziata ||  getObj('ProceduraGara').value == ProceduraEconomia ) {
        if  ( getObj('ProtocolBG').value == '' ){
            aggiungivoce ( ObjTipoBandoCompleto , 'TipoBando' , Avviso );
            aggiungivoce ( ObjTipoBandoCompleto , 'TipoBando' , Invito );
        }else{
          if ( strRettifica != 'si' ){
            rimuovivoce ( 'TipoBando' , Avviso );
            aggiungivoce ( ObjTipoBandoCompleto , 'TipoBando' , Invito );
          }
        }
      }
      
      //se si tratta di Richiesta di Preventivo allora solo invito ammesso
      if  ( getObj('ProceduraGara').value == ProceduraRDP  ) 
            aggiungivoce ( ObjTipoBandoCompleto , 'TipoBando' , Invito );
      
      //se si tratta di Richiesta di informazioni allora solo invito ammesso
      if  ( getObj('ProceduraGara').value == ProceduraRDI  ) 
            aggiungivoce ( ObjTipoBandoCompleto , 'TipoBando' , Invito );
      
    }catch(e){
      
    } 
    
    
    //setta caption del documento
    if ( getObj('ProceduraGara').value != '' && getObj('TipoBando').value != '' ){
      var KEYML = 'message_55_167_' + getObj('ProceduraGara').value + '_' + getObj('TipoBando').value ;
      //gestita eccezione per quando vine aperto in un contesto in cui la caption del documento non è visualizzata
      try{
        getObj('CaptionDocument').innerHTML = CNVAJAX ('../../' , KEYML ) ; 
      }catch(e){}
      
    }
     
    //Setto gli attributi EvidenziaPubblica , RichiestaQuesito , FaseGara , Sezionedestinatari
    SetAttributiFromTipoBando( nsvuotacombo );
  
  }
  
  
  //Setto gli attributi EvidenziaPubblica , RichiestaQuesito , FaseGara , Sezionedestinatari
  function SetAttributiFromTipoBando( nsvuotacombo ){
    
     try{
        Old_TipoBando_onchange();
     }catch(e){
     }
    
    //setta caption del documento
    if ( getObj('ProceduraGara').value != '' && getObj('TipoBando').value != '' ){
      var KEYML = 'message_55_167_' + getObj('ProceduraGara').value + '_' + getObj('TipoBando').value ;
      getObj('CaptionDocument').innerHTML = CNVAJAX ('../../' , KEYML ) ; 
    }
    
    //alert('SetAttributiFromTipoBando=' + nsvuotacombo);
    
    if ( nsvuotacombo != 0 ){
       
       try{
        svuota( 'EvidenzaPubblica' , '' );
       } catch(e){}
       
       try{ 
        svuota( 'RichiestaQuesito' , '' );
       } catch(e){}
       
       try{  
        svuota( 'FaseGara' , '' );
       } catch(e){}
       
    }
 
    
    
      if  ( getObj('TipoBando').value == Bando ||  getObj('TipoBando').value == Avviso ) {
        
        try{    
          //setta EvidenzaPubblica
          aggiungivoce ( ObjEvidenzaPubblicaCompleto , 'EvidenzaPubblica' , '1' );
        }catch(e){
        }    
        
        try{
          //setta RichiestaQuesito
          aggiungivoce ( ObjRichiestaQuesitoCompleto , 'RichiestaQuesito' , '1' );
          aggiungivoce ( ObjRichiestaQuesitoCompleto , 'RichiestaQuesito' , '2' );
        }catch(e){
        }
        
      }
      
      if  ( getObj('TipoBando').value == Invito ) {
        
        try{
          //setta EvidenzaPubblica
          aggiungivoce ( ObjEvidenzaPubblicaCompleto , 'EvidenzaPubblica' , '0' );
          aggiungivoce ( ObjEvidenzaPubblicaCompleto , 'EvidenzaPubblica' , '1' );
        }catch(e){
        } 
        
        try{
          //setta RichiestaQuesito
          aggiungivoce ( ObjRichiestaQuesitoCompleto , 'RichiestaQuesito' , '3' );
        }catch(e){
        }
        
      }
    
    
     
    //setta FaseGara
    if  ( getObj('TipoBando').value == Avviso ) {
      aggiungivoce ( ObjFaseGaraCompleto , 'FaseGara' , FaseGara_Qualifica );
      nhideDestinatari=1 ;
    }
    
    if  ( getObj('TipoBando').value == Invito ) {
        aggiungivoce ( ObjFaseGaraCompleto , 'FaseGara' , FaseGara_PresentazioneOfferte );
        nhideDestinatari=0 ;
    }
    
      
    if  ( getObj('TipoBando').value == Bando ) {
      nhideDestinatari=1 ;
      if  ( getObj('ProceduraGara').value == ProceduraAperta  ) 
        aggiungivoce ( ObjFaseGaraCompleto , 'FaseGara' , FaseGara_PresentazioneOfferte );
      else
        aggiungivoce ( ObjFaseGaraCompleto , 'FaseGara' , FaseGara_Qualifica );
    }
    
    
    
    //se la sezione dei destinatari non si nasconde allora è obblig inserire almeno un destinatario
    if ( nhideDestinatari == 0)
      obbligDestinatari = 1 ;
    
    //sezione destinatari
    try{
      hObjSection = getObj( 'CompanyDes_Hide' );                   
      hObjSection.value = nhideDestinatari ;      
    }catch(e){
      //creo a volo il campo nascosto per gestire la sezione CompanyDes
      createNewFormElement(document.new_document, "CompanyDes_Hide",  1 );
    }
    
    //setto il campo QuesitoAnonimo a no se Procedura Aperta-bando oppure Procedura Ristretta-bando
    if ( ( getObj('ProceduraGara').value == ProceduraAperta || getObj('ProceduraGara').value == ProceduraRistretta ) && getObj('TipoBando').value == Bando )
      getObj('QuesitoAnonimo').value = '0';
    
    //nascondo le buste a secondo di ProceduraGara e TipoBando
    HideBusteFromProgeduraGara_TipoBando();
    
     
  }
	
	
  //nasconde la sezione dei lotti infunzione del campo di copertina Divisione_lotti
  function SetInfoLotti(){
    
    try{
        Old_Divisione_lotti_onchange();
    }catch(e){
    }
    
    //SE (ProceduraGara=RISTRETTA e TipoBando=BANDO) oppure (ProceduraGara=ECONOMIA/MARKETPLACE e TipoBando=BANDO)
    //gestione dei lotti la metto a no
    if  ( ( getObj('ProceduraGara').value == ProceduraRistretta && getObj('TipoBando').value == Bando ) || ( ( getObj('ProceduraGara').value == ProceduraNegoziata || getObj('ProceduraGara').value == ProceduraEconomia ) && getObj('TipoBando').value == Avviso ) ) {
		  getObj('Divisione_lotti').value='0';
		  
		  return;
	  }
    
    try{
      
      //VISUALIZZO area comune e prima area griglia della SEZIONE TECNICA  
      getObj( 'TECNICA_griglia' ).style.display = 'inline' ;
      getObj( 'TECNICA_comune' ).style.display = 'inline' ;
      getObj( 'command_TECNICA_comune' ).style.display = 'inline' ;
      getObj( 'command_TECNICA_griglia' ).style.display = 'inline' ;
      
    
      //NASCONDO LE COLONNE DocPerTuttiLotti e LottiPerDoc della griglia attidigara della sezione TECNICA
      //ShowCol( 'TECNICA_attidigara' , 'DocPerTuttiLotti' , 'none' );
      ShowCol( 'TECNICA_attidigara' , 'LottiPerDoc' , 'none' );
    }catch(e){}
    
    
    //NE LOTTI E NE MICROLOTTI NASCONDO ENTRAMBE LE SEZIONI
    if ( getObj( 'Divisione_lotti' ).value == '0' || getObj( 'Divisione_lotti' ).value == '' ){
        
        try{
          hObjSection = getObj( 'GestioneLotti_Hide' );                   
          hObjSection.value = 1 ;                                               
        }catch(e){
          //creo a volo il campo nascosto per gestire la sezione GestioneLotti
          createNewFormElement(document.new_document, "GestioneLotti_Hide",  1 );
        }
          
        
        try{
          hObjSection = getObj( 'MicroLotti_Hide' );                   
          hObjSection.value = 1 ;                                
          hObjSection = getObj( 'OFFERTAECONOMICAMICROLOTTI_Hide' );                   
          hObjSection.value = 1 ;                                
        }catch(e){
          //creo a volo il campo nascosto per gestire la sezione MicroLotti
          createNewFormElement(document.new_document, "MicroLotti_Hide",  1 );
          
          //creo a volo il campo nascosto per gestire la sezione OFFERTAECONOMICAMICROLOTTI
          createNewFormElement(document.new_document, "OFFERTAECONOMICAMICROLOTTI_Hide",  1 );
          
        }
        
        
        hObjSection = getObj( 'ECONOMICA_Hide' );                   
        hObjSection.value = 0 ; 
        
         
         try{
            //VISUALIZZO CREA PDA CLASSICO
            getObj( 'OPEN_CREATE_12' ).style.display='inline'; 
            try { getObj( 'IMG_OPEN_CREATE_12' ).style.display='inline'; }catch(e){}
            
          } catch(e){  
            
            try { getObj( 'LNK_OPEN_CREATE_12' ).style.display='inline'; }catch(e){}
            try { getObj( 'IMG_OPEN_CREATE_12' ).style.display='inline'; }catch(e){}
            
          };
        
        
        try{
    
          //NASCONDO CREA PDA MICROLOTTI
          getObj( 'OPENURL_7' ).style.display='none'; 
          try { getObj( 'IMG_OPENURL_7' ).style.display='none'; }catch(e){}
    
        } catch(e){ 
          
          try { getObj( 'LNK_OPENURL_7' ).style.display='none'; }catch(e){}
          try { getObj( 'IMG_OPENURL_7' ).style.display='none'; }catch(e){}
        }
    } 
    
    
    //SE LOTTI TRADIZIONALI NASCONDO SOLO MICROLOTTI
    if ( getObj( 'Divisione_lotti' ).value == '1'  ){
      
        hObjSection = getObj( 'GestioneLotti_Hide' );                   
        hObjSection.value = 0;                                               
      
        hObjSection = getObj( 'MicroLotti_Hide' );                   
        hObjSection.value = 1;                                
        
        try{
          hObjSection = getObj( 'OFFERTAECONOMICAMICROLOTTI_Hide' );                   
          hObjSection.value = 1 ;   
        }catch(e){}
        
        hObjSection = getObj( 'ECONOMICA_Hide' );                   
        hObjSection.value = 0 ; 
        
        try{
          
          //VISUALIZZO CREA PDA CLASSICO
          getObj( 'OPEN_CREATE_12' ).style.display='inline';
          try { getObj( 'IMG_OPEN_CREATE_12' ).style.display='inline'; }catch(e){}
          
        } catch(e){  
          
            try { getObj( 'LNK_OPEN_CREATE_12' ).style.display='inline'; }catch(e){}
            try { getObj( 'IMG_OPEN_CREATE_12' ).style.display='inline'; }catch(e){}
          }
        
        try{
          //NASCONDO CREA PDA MICROLOTTI
          getObj( 'OPENURL_7' ).style.display='none';
          try { getObj( 'IMG_OPENURL_7' ).style.display='none'; }catch(e){}
          
        } catch(e){  
            try { getObj( 'LNK_OPENURL_7' ).style.display='none';  }catch(e){}
            try { getObj( 'IMG_OPENURL_7' ).style.display='none'; }catch(e){}
          }
      
    }
   
   //SE MICROLOTTI NASCONDO LOTTI e BUSTA ECONOMICA CLASSICA
   if ( getObj( 'Divisione_lotti' ).value == '2'  ){
      
        hObjSection = getObj( 'GestioneLotti_Hide' );                   
        hObjSection.value = 1 ;                                               
        
        hObjSection = getObj( 'MicroLotti_Hide' );                   
        hObjSection.value = 0 ;                                
        
        try{
          hObjSection = getObj( 'OFFERTAECONOMICAMICROLOTTI_Hide' );                   
          hObjSection.value = 0 ;  
        }catch(e){}
        
        hObjSection = getObj( 'ECONOMICA_Hide' );                   
        hObjSection.value = 1 ;                                               
        
        
        
        try{
          
          //NASCONDO area comune e prima area griglia della SEZIONE TECNICA
          getObj( 'TECNICA_griglia' ).style.display = 'none' ;
          getObj( 'TECNICA_comune' ).style.display = 'none' ;
          getObj( 'command_TECNICA_griglia' ).style.display = 'none' ;
          getObj( 'command_TECNICA_comune' ).style.display = 'none' ;
          
          //VISUALIZZO LE COLONNE DocPerTuttiLotti e LottiPerDoc della griglia attidigara della sezione TECNICA
          //ShowCol( 'TECNICA_attidigara' , 'DocPerTuttiLotti' , '' );
          ShowCol( 'TECNICA_attidigara' , 'LottiPerDoc' , '' );
          
        }catch(e){}
        
        try{
         //VISUALIZZO CREA PDA MICROLOTTI
          getObj( 'OPENURL_7' ).style.display='inline';
          try { getObj( 'IMG_OPENURL_7' ).style.display='inline'; }catch(e){}
        } catch(e){ 
            try { getObj( 'LNK_OPENURL_7' ).style.display='inline'; }catch(e){}
            try { getObj( 'IMG_OPENURL_7' ).style.display='inline'; }catch(e){}
          }  
        
        try{
          //NASCONDO CREA PDA CLASSICO
          getObj( 'OPEN_CREATE_12' ).style.display='none';
          try { getObj( 'IMG_OPEN_CREATE_12' ).style.display='none'; }catch(e){}
        } catch(e){  
          try {   getObj( 'LNK_OPEN_CREATE_12' ).style.display='none'; }catch(e){}
          try { getObj( 'IMG_OPEN_CREATE_12' ).style.display='none'; }catch(e){}
          }
          
        
        
        
        //se selezionato un modello allora carico nell'area URL il viewer
        //per visualizzare il modello di micro lotto caricato
        DisplayAreaUrlMicroLotto();
        
        //se critrio offerta + vantaggiosa nelle colonne 
        //DocPerTuttiLotti e LottiPerDoc della griglia attidigara della sezione TECNICA
        //inserisco link per aprire lista lotti da associare ad un doc
        if ( getObj('CriterioAggiudicazioneGara').value == PDA_OffertaVantaggiosa )
          SetLinkLottiPerDoc();  
    }
    
    
    DrawLabel( LinkAttivo ); 
    
    //se documento non è in sola lettura setto il campo della firma  coerentemente in funzione del campo Divisione_lotti
    if ( getObj('Stato').value == '0' ||  ( getObj('Stato').value == '1' && getObj('AdvancedState').value!='4' && getObj('AdvancedState').value!='5') )
      SetFirmaBusta();
  
  }
  

	
	
	//setta firma busta a seconda di Divisione_lotti e ClausolaFideiussoria
	function SetFirmaBusta(){
    
    if ( getObj( 'Divisione_lotti' ).value == '2'  ){
      
      //MICROLOTTI
      if ( getObj('ClausolaFideiussoria').value == '1' ) {
      
        svuota( 'RequestSignTemp' , FirmaBusta_SI_CAUZIONE );
        aggiungivoce ( ObjFirmaBustaCompleto , 'RequestSignTemp' , FirmaBusta_SI_CAUZIONE );  
        
      }else{
        
        rimuovivoce ( 'RequestsignTemp' , FirmaBusta_SI_CAUZIONE );
        rimuovivoce ( 'RequestsignTemp' , FirmaBusta_SI );
        rimuovivoce ( 'RequestsignTemp' , FirmaBusta_SI_ECONOMICA );
        aggiungivoce ( ObjFirmaBustaCompleto , 'RequestSignTemp' , FirmaBusta_NO );
        aggiungivoce ( ObjFirmaBustaCompleto , 'RequestSignTemp' , FirmaBusta_SI_MICROLOTTI );
        
      }
      
    }else{
      
      // NO MICROLOTTI
      rimuovivoce ( 'RequestSignTemp' , FirmaBusta_SI_MICROLOTTI );
      rimuovivoce ( 'RequestSignTemp' , FirmaBusta_SI_CAUZIONE );
      aggiungivoce ( ObjFirmaBustaCompleto , 'RequestSignTemp' , FirmaBusta_NO );
      aggiungivoce ( ObjFirmaBustaCompleto , 'RequestSignTemp' , FirmaBusta_SI );
      aggiungivoce ( ObjFirmaBustaCompleto , 'RequestSignTemp' , FirmaBusta_SI_ECONOMICA );
      
    }
      
      
  }
	
	
	
	
  function aggiungivoce( ObjSourceList , DestListName ,  value_selezionato ){
    	
    	var duplicato=0;
    	
    	
    	//alert(value_selezionato);
      if (ObjSourceList.options.length >= 0 ){
  		 
        //recupero il nodo da aggiungere dalla lista completa 
  		  for(a=0; a < ObjSourceList.options.length; a++){
  				if( ObjSourceList.options[a].value == value_selezionato ){
  					value_selezionato = ObjSourceList.options[a].value;
  			    testo_selezionato = ObjSourceList.options[a].innerHTML;
  			    break;
  				}
  			}
  			
  			//controllo che nn è già presente nella lista corrente
  			num_option=getObj( DestListName ).options.length; 
      	duplicato=0;
  		  for(a=0;a<num_option;a++){
  		    
  				if( getObj( DestListName ).options[a].value == value_selezionato ){
  				  //alert(value_selezionato + '-presente in -' + DestListName );
  					duplicato=1;
  					break;
  				}
  			}
  			//alert(value_selezionato + 'in ' + DestListName + '-duplicato=' + duplicato);
  			if(duplicato==0){
  				getObj( DestListName ).options[num_option]=new Option('',value_selezionato,false,false);
  				getObj( DestListName ).options[num_option].innerHTML = testo_selezionato;
  			}
      
      }
      
  }
	
	
	
	
	function rimuovivoce( ListName , value_selezionato ){
		
		num_option=getObj( ListName ).options.length;
		
    for(a=0;a<num_option;a++){
  		if(getObj( ListName ).options[a].value == value_selezionato){
  			getObj( ListName ).options[a]=null;
  			break;
  		}
		}
		
	}

  function SelectedListValue( ListName  ){
		
		num_option=getObj( ListName ).options.length;
		
    for(a=0;a<num_option;a++){
  		if(getObj( ListName ).options[a].selected ){
  			return getObj( ListName ).options[a].value ;
  		}
		}
		
	}

  //svuota una select NameList tranne l'elemento selElement
	function svuota( NameList , selElement ){
		num_option=getObj(NameList).options.length;
		for(a=num_option-1 ; a>=0 ;a--){
		  if ( getObj(NameList).options[a].value != selElement  )
			   getObj(NameList).options[a]=null;
		}
	}
	
	
	//effettua una copia di un oggetto select
	function CopiaListaCompleta( ListNameSource  ){
    
    //creo la lista completa di copia di CriterioDiValutazione
    var objListDest = document.createElement("select");
    num_option=getObj(ListNameSource).options.length;
    for(a=0;a<num_option;a++){
    
      var newSelectOption = document.createElement('option');
      newSelectOption.setAttribute('value', getObj(ListNameSource).options[a].value);
      textForOption=document.createTextNode(getObj(ListNameSource).options[a].innerHTML );
      newSelectOption.appendChild(textForOption);
      
  		objListDest.appendChild ( newSelectOption );
		}
    return objListDest;
       
  }
	
	
	function HandleCampiMicroLotti(){
  
    var objListaModelli = getObj( 'elemento_MicroLotti_MicrolottoComune_' + get_IdDztFromDztNome_AreaOfid('MicroLotti_MicrolottoComune','ListaModelliMicrolotti') );
              
    objListaModelli.onchange = DownLoadModelloMicroLotto ;
    
    //prima di fare upload del microlotto controllo che sia selezionato un modello di microlotto
    var objButtonMicrolottoAllegato = getObj( 'Button_elemento_MicroLotti_MicrolottoComune_' + get_IdDztFromDztNome_AreaOfid('MicroLotti_MicrolottoComune','MicrolottoAllegato') );
    Old_MicrolottoAllegato_onclick = objButtonMicrolottoAllegato.onclick ;
    objButtonMicrolottoAllegato.onclick = CheckForUpLoadMicrolotto ;
    
      
  }
	
	
	//controlla se è stato selezionato un modello prima di fare upload del microlotto
	function CheckForUpLoadMicrolotto(){
	   
	   var objListaModelli = getObj( 'elemento_MicroLotti_MicrolottoComune_' + get_IdDztFromDztNome_AreaOfid('MicroLotti_MicrolottoComune','ListaModelliMicrolotti') );   
	   if (objListaModelli.value==''){
	       alert( CNVAJAX ('../../' , 'Selezionare un modello di microlotto' ) );
	       return;   
     }else{
	     try{
        Old_MicrolottoAllegato_onclick();
       }catch(e){
       }
     }
  
  }
	
	function DownLoadModelloMicroLotto(){
    
    
    
    var objCell = getObj( 'Cella_elemento_MicroLotti_MicrolottoComune_' + get_IdDztFromDztNome_AreaOfid('MicroLotti_MicrolottoComune','ListaModelliMicrolotti') ) ;
    var objListaModelli = getObj( 'elemento_MicroLotti_MicrolottoComune_' + get_IdDztFromDztNome_AreaOfid('MicroLotti_MicrolottoComune','ListaModelliMicrolotti') );   
    
    
    
    if (objListaModelli.value != '') {
      
      
      //chiamata ajax che recupera info per fare download del modello
      ajax = GetXMLHttpRequest(); 
  
    	if(ajax){
    		  
          
    		  ajax.open("GET", '../../CustomDoc/GetInfoModelloMicrolotto.asp?CODICE=' + escape( objListaModelli.value ), false);
    	 		 
    			ajax.send(null);
    			
    			if(ajax.readyState == 4) {
    			
    				if(ajax.status == 200)
    				{
    				  //alert(ajax.responseText);
    				  if ( ajax.responseText != '' ) {
    				    
    				    try{
                  objCell.removeChild( getObj('div_downloadMicrolotto') );
                }catch(e){}
    				  
    				    var ainfo=ajax.responseText.split('@@@');
    				    var objDivTemp = document.createElement('div');
    				    objDivTemp.setAttribute('id','div_downloadMicrolotto');
    				    objDivTemp.innerHTML =  ainfo[0];
    				    objCell.appendChild(objDivTemp);
    				    
    				    //aggiorno campo in copertina che salva ilmodello selezionato
    				    getObj('ListaModelliMicrolotti').value = objListaModelli.value ;
    				    
              }
    				}
    			}
    
    	}
      
      
      
      
    }else{
     
      
      try {
        
        //rimuovo area del download del modello se era presente
        try{
          objCell.removeChild( getObj('div_downloadMicrolotto') );
        }catch(e){}
        
        //svuoto il campo di copertina che memorizza il modello
        getObj('ListaModelliMicrolotti').value = '' ;
        
        //se sotto avevo già importato un catalogo allora svuoto i dettagli importati
        var objMicrolottoAllegato = getObj( 'elemento_MicroLotti_MicrolottoComune_' + get_IdDztFromDztNome_AreaOfid('MicroLotti_MicrolottoComune','MicrolottoAllegato') );
        if (objMicrolottoAllegato.value != ''){
          
          //svuoto il campo che contine allegato
          objMicrolottoAllegato.value='';
            
          //lancio il processo per svuotare i dettagli del microlotto
          ExecDocProcessLight( 'RESET_MICROLOTTI,BANDO' );
          
        }
        
      }catch(e){}
      
    }
      
  }
	
	//Visualizza il viewer del microlotto caricato
	function DisplayAreaUrlMicroLotto(){
  
    var objListaModelli = getObj( 'elemento_MicroLotti_MicrolottoComune_' + get_IdDztFromDztNome_AreaOfid('MicroLotti_MicrolottoComune','ListaModelliMicrolotti') );
    
    
    //strURL = '../DASHBOARD/Viewer.asp?PATHTOOLBAR=../customdoc/&JScript=&Exit=&Table=DASHBOARD_VIEW_MODELLI_MICROLOTTI&OWNER=&IDENTITY=ID&TOOLBAR=&DOCUMENT=&AreaAdd=no&CaptionNoML=no&Caption=&Height=0,100*,210&numRowForPag=25&Sort=NumeroLotto&SortOrder=asc&ACTIVESEL=0&FILTERCOLUMNFROMMODEL=yes&AreaFiltroWin=0&AreaFiltro=no&' + FilterHide;
     
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
                var ModelloBando=ainfo[1];
                //alert(ModelloBando);
    				  }
    				}
    			}
    
    	}
      
      
      var IdHeader = getObj('lIdMsgPar').value
      var strURL = '../../DASHBOARD/Viewer.asp?PATHTOOLBAR=../customdoc/&JScript=&Exit=&Table=Document_MicroLotti_Dettagli&OWNER=&IDENTITY=ID&TOOLBAR=&DOCUMENT=&AreaAdd=no&CaptionNoML=no&Caption=&Height=0,100*,210&numRowForPag=25&Sort=cast(NumeroLotto as int)&SortOrder=asc&ACTIVESEL=1&AreaFiltroWin=0&AreaFiltro=no&TOTAL=Totale,4&';  
      //var  FilterHide = 'FilterHide = TipoDoc=\'' + TipoDoc + '\' and IdHeader=' + IdHeader ;
      var  FilterHide = 'FilterHide=IdHeader=' + IdHeader ;
      strURL = strURL + FilterHide ;
      strURL = strURL + '&ModGriglia=' + ModelloBando ;
      
      getObj('iframe_MicroLotti_MicrolottoUrl').src = strURL;
      
      getObj('iframe_OFFERTAECONOMICAMICROLOTTI_MicrolottoUrl').src = strURL;
      
       
    }
	 
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
	
	
	//esegue azioni sulla area attidigara della sezione TECNICA
	function CustomActionOnGrid ( strFullNameArea , Param ){
	
	   if ( strFullNameArea == 'TECNICA_attidigara'){
      
        if ( getObj( 'Divisione_lotti' ).value == '2'  ){
          
          //VISUALIZZO LE COLONNE DocPerTuttiLotti e LottiPerDoc della griglia attidigara della sezione TECNICA
          try{
            //ShowCol( 'TECNICA_attidigara' , 'DocPerTuttiLotti' , '' );
            ShowCol( 'TECNICA_attidigara' , 'LottiPerDoc' , '' );
            
            SetLinkLottiPerDoc();
            
          }catch(e){}
          
          
          
        }else {
          
          //VISUALIZZO LE COLONNE DocPerTuttiLotti e LottiPerDoc della griglia attidigara della sezione TECNICA
          try{
            //ShowCol( 'TECNICA_attidigara' , 'DocPerTuttiLotti' , 'none' );
            ShowCol( 'TECNICA_attidigara' , 'LottiPerDoc' , 'none' );
          }catch(e){}
          
        }
     }
     
     //OPERAZIONI SULLA BUSTA TECNICA 
     if ( strFullNameArea == 'TECNICA_griglia'){
        
        var bUpdateCriteri = false;
        
        //cambio onchange colonna Descrizione in caso di righe ditipo QUIZ   
        SetOnChangeDescTecnicaForQuiz();
        
        
        if ( Param != undefined ){
        
         if  ( Param != '' ){
         
           var aInfo = Param.split('&');
           
           //CANCELLA RIGHE allora aggiorno anche i criteri tecnici
           if (aInfo[0] == 'OPERATION=4' ){
                   
              //quando eseguo operazioni di camcellazione sulla busta tecnica vado ad aggiornare la griglia dei CRITERI     
              //se sulla griglia dei CRITERI esiste attributo CriterioDiValutazioneQuiz allora
              //aggiorno tutta la griglia dei criteri
              //var strAttribTecnica = getObj('DZTNOME_TECNICA_griglia').value;
              //alert(strAttribTecnica);
              //alert(strAttribTecnica.indexOf('CriterioDiValutazioneQuiz', 0));
              //if ( strAttribTecnica.indexOf('CriterioDiValutazioneQuiz', 0) >= 0 )
              
              bUpdateCriteri = true ;
              
           }
           
           //COPIA RIGA/E allora aggiorno anche i criteri tecnici
           if ( aInfo[0] == 'OPERATION=3' ){
              
              var strAttribTecnica = getObj('DZTNOME_TECNICA_griglia').value;
              if ( strAttribTecnica.indexOf('CriterioDiValutazioneQuiz', 0) >= 0 ){
                
                //rendo univoca la descrizione dei criteri copiati
                var strInfoCopia = aInfo[1];
                var aInfoElem = strInfoCopia.split('=');
                var strListIdCopiati = aInfoElem[1];
                var aIdCopiati = strListIdCopiati.split(',');
                var nNumCopiati = aIdCopiati.length;
                
                //alert(nNumCopiati);
                
                var objRow=getObj('NumProduct_'+ strFullNameArea);
                var nNumRow=Number(objRow.value);
                var nPosDesc=GetColumnPositionInGrid('DescrAttach',strFullNameArea);
                
                var i;
                for ( i=0; i<nNumCopiati; i++){	
                  
                  getObj(strFullNameArea + '_' + (nNumRow-i) + '_' + nPosDesc ).value = (nNumRow-i) + ' ' +  getObj(strFullNameArea + '_' + (nNumRow-i) + '_' + nPosDesc ).value ;
          
                }
                
                //aggiungo la condizione per riaggiornare la busta tecnica lato server
                Param = Param + '&UpdateTecnica=YES';
                bUpdateCriteri = true ;
              }
             
           }
           
           //se richiesto aggirono anche i criteri
           if ( bUpdateCriteri ) 
            AggiornaCriteriTecnici( '' , Param , '../../ctl_library/' );
       
         }
         
         
        }
           
     }
     
     //OPERAZIONI GRIGLIA DEI CRITERI 
     if ( strFullNameArea == 'CRITERI_griglia'){
        
        //disabilito le righe a QUIZ
        DisableCriteriQuiz();
     }
     
     //OPERAZIONI SULLA GRIGLIA BUSTA ECONOMICA
     if ( strFullNameArea == 'ECONOMICA_griglia'){
        
        //nascondo colonna Valore Offerta
        HideValoreOffertoBustaEconomica();
     }
	 
	  //OPERAZIONI SULLA GRIGLIA BUSTA DOCUMENTAZIONE
     if ( strFullNameArea == 'DOCUMENTAZIONE_griglia'){
        
        //nascondo colonna Allegato
        HideAllegatoBustaEconomica();
     }
     
     
  }
	
	//controlla se sono settati coerentemente le colonne  DocPerTuttiLotti e LottiPerDoc della griglia attidigara della sezione TECNICA
	function CheckLottiPerDoc(){
  
    var strNameControl='TECNICA_attidigara' ;
    //var nPos=GetColumnPositionInGrid('DocPerTuttiLotti',strNameControl);
    var nPos1=GetColumnPositionInGrid('LottiPerDoc',strNameControl);
    var bEsito=true;
    if ( nPos > 0){
      
      var objRow=getObj('NumProduct_'+ strNameControl);
      var nNumRow=Number(objRow.value);
      
      for ( nIndRrow=1; nIndRrow<=nNumRow; nIndRrow++){	
        
        if ( getObj(strNameControl + '_' + nIndRrow + '_' + nPos ).value != '10099' && getObj(strNameControl + '_' + nIndRrow + '_' + nPos1 ).value == '' ){
          bEsito = false
          break;  
        }
        
        if ( getObj(strNameControl + '_' + nIndRrow + '_' + nPos ).value == '10099' && getObj(strNameControl + '_' + nIndRrow + '_' + nPos1 ).value != '' ){
          bEsito = false
          break;  
        }
        
      }
      
    }
  
    return bEsito;
    
  }
  
  //sulla colonna LottiPerDoc setta un link per aprire la lista lotti e selezionare quelli associati al doc
  function SetLinkLottiPerDoc(){
  
    var strNameControl='TECNICA_attidigara' ;
    var nPos=GetColumnPositionInGrid('LottiPerDoc',strNameControl);
   
    if ( nPos != -1 ){
    
      var objRow=getObj('NumProduct_'+ strNameControl);
      var nNumRow=Number(objRow.value);
      
      //var strSpanClick = '';   
      var strTechValue = '' ; 
      
      for ( nIndRrow=1; nIndRrow<=nNumRow; nIndRrow++){	
        
        strTechValue=getObj('TECNICA_attidigara_' + nIndRrow + '_' + nPos ).value;
        //alert(strTechValue);
        AggiornaListaLottiPerDoc( nIndRrow,  strTechValue );
        //strSpanClick = '<span class="TextLink" onclick="javascript:SelezionaLotti(\'' + nIndRrow + '\');">Sel. Lotti</span>';  
        //getObj('cell_TECNICA_attidigara_' + nIndRrow + '_' + nPos ).innerHTML =  getObj('cell_TECNICA_attidigara_' + nIndRrow + '_' + nPos ).innerHTML + '<br>' + strSpanClick  ;
        
      }
      
    }
  
  }
	
	//per ogni riga di documento allegato apre il viewer con la lista dei lotti 
	function SelezionaLotti( indRow ){
    
    var strNameControl='TECNICA_attidigara' ;
    var nPos=GetColumnPositionInGrid('LottiPerDoc',strNameControl);
    var nPosAttach=GetColumnPositionInGrid('Attach',strNameControl);
    
    //apro viewer per selezionare i lotti associati al doc nella riga indRow
    var IdHeader = getObj('lIdMsgPar').value
    if ( IdHeader != "-1" ){
      
        //recupero nome allegato della riga
        //47#~31315 - Interna - modifica multilinguismo.txt
        var TechValueAttach=getObj(strNameControl + '_' + indRow + '_' + nPosAttach ).value;
        
        if ( TechValueAttach == '') 
          alert( CNVAJAX ('../../' , 'Selezionare prima il documento della riga' ) ); 
        else{
          var ainfodoc=TechValueAttach.split('#~');
          
          var strCaption = CNVAJAX ('../../' , 'Lista Lotti associata al documento' ) + '&nbsp;' + escape( '"' + ainfodoc[1] + '"');
          
          var strToolbar='';
          if ( getObj('Stato').value == '0' || getObj('Stato').value == '1')
            strToolbar='LISTALOTTI_DOC_TOOLBAR';
          
          var strURL = '../../DASHBOARD/Viewer.asp?AreaInfo=yes&INFO_H=80&PATHTOOLBAR=../customdoc/&JScript=ListaLottiDocumento&Exit=si&Table=Document_MicroLotti_Dettagli&OWNER=&IDENTITY=ID&TOOLBAR=' + strToolbar + '&DOCUMENT=&AreaAdd=no&CaptionNoML=no&Caption=' + strCaption + '&Height=0,100*,210&numRowForPag=2000&Sort=cast(NumeroLotto as int)&SortOrder=asc&ACTIVESEL=2&AreaFiltroWin=0&AreaFiltro=no&TOTAL=&';  
          var  FilterHide = 'FilterHide=IdHeader=' + IdHeader ;
          strURL = strURL + FilterHide ;
          strURL = strURL + '&ModGriglia=Microlotto_ListaLotti_Documento&RigaDocumento=' + indRow + '#listalotti#800,600';
          ExecFunctionCenter(strURL);
        }  
      
    }else{
          
          alert( CNVAJAX ('../../' , 'Allegare microlotto' ) );
          DrawLabel('5'); 
          FUNC_MicroLotti();
          getObj( 'Button_elemento_MicroLotti_MicrolottoComune_' + get_IdDztFromDztNome_AreaOfid('MicroLotti_MicrolottoComune','MicrolottoAllegato') ).focus();
          return;
      
    
    }
    
    
  }
  
  //aggiorna i lotti per il documento allegato
  function AggiornaListaLottiPerDoc( indRow, result ){
  
    var strNameControl='TECNICA_attidigara' ;
    var nPos=GetColumnPositionInGrid('LottiPerDoc',strNameControl);
    var strListaLotti='';
    var ainfo;
    var i;
    var ainfoparam;
    var strDesc='';
    
    strSpanClick = '<input class="Attach_button" type=button value="..." class="TextLink" onclick="javascript:SelezionaLotti(\'' + indRow + '\');" >';  
    
    
    if ( result != ''){
    
      ainfo=result.split('~~~');
      
      for ( i = 0 ; i < ainfo.length ; i++ ){
        
        ainfoparam = ainfo[i].split('@@@');
        
        if ( strListaLotti != '' ) strListaLotti = strListaLotti +  ', ';
  				
        strListaLotti = strListaLotti  + ainfoparam[1] ;
      
      }
    }
    
    if (strListaLotti == '') 
      strDesc= ' ' + CNVAJAX ('../../' , 'Tutti i Lotti' ) + ' ' ;
    else
      strDesc= '<b>'  + ainfo.length + '</b> ' + CNVAJAX ('../../' , 'Lotti Selezionati' ) + ' ';
      
    getObj('cell_TECNICA_attidigara_' + indRow + '_' + nPos ).innerHTML = strDesc + strSpanClick;
    
    //aggiorno campo nascosto tecnico
    getObj('TECNICA_attidigara_' + indRow + '_' + nPos ).value =  result ;
  
  }
  
  
  
  function onChangeAnomalia()
  {
  	
  	//invoco vecchio onchange
  	try{
  		Old_CalcoloAnomalia_onchange();
  		}catch(e){
  		
  	}
  	
  	var anomalia = getObj('CalcoloAnomalia').value;
  	
  	
  	
  	if (anomalia == '0') //selezione su NO
  	{
  		
  		setStyleProp(getObj('lblOffAnomale'),'visibility','hidden');
  		setStyleProp(getObj('OffAnomale'),'visibility','hidden');
  		
  		try{
  			setStyleProp(getObj('OffAnomale_vis'),'visibility','hidden');  
  			}catch(e){
  		}
  		
  		
  		
  	}
  	else
  	{
  		
  		setStyleProp(getObj('lblOffAnomale'),'visibility','visible');
  		setStyleProp(getObj('OffAnomale'),'visibility','visible');
  		
  		try{
  			setStyleProp(getObj('OffAnomale_vis'),'visibility','visible');  
  			}catch(e){
  		}
  		
  		
  		
  	}
  }
  
  
  function setStyleProp(campo,prop,value)
  {
  	if (document.all != null) //Explorer
  	campo.style.setAttribute(prop,value);
  	else
  	campo.setAttribute('style',prop + ':' + value);
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
  
	
	//Serve ad aggiornare la griglia dei CRITERI TECNICI con il Criterio a QUIZ
	function AggiornaCriteriTecnici( strField , Param , Path ){
	  
    //visualizzo loading  per segnalare elaborazione in corso
    getObj('INFO_PROCESS').style.display='';
    
    
    const_width=300;
	  const_height=150;
	  sinistra=(screen.width-const_width)/2;
	  alto=(screen.height-const_height)/2;
    
    winCriteri=window.open('','winCriteri','toolbar=no,location=no,directories=no,status=yes,menubar=no,resizable=yes,copyhistory=no,scrollbars=no,width='+const_width+',height='+const_height+',left='+sinistra+',top='+alto+',screenX='+sinistra+',screenY='+alto+'');
    winCriteri.document.write('<link rel="stylesheet" href="' + Path + 'Themes/MsgBox.css" type="text/css">');
		winCriteri.document.write('<title>' + CNVAJAX ('../../' , 'Aggiornamento Criteri tecnici' ) + '</title>');
		winCriteri.document.write('<table class="INFO_BOX" cellpadding=0 cellspacing=0><tr><td align=center class=caption>' + CNVAJAX ('../../' , 'Attenzione' ) + '</td></tr>');
		winCriteri.document.write('<tr><td class=elaborazione><img src="' + Path + 'images/grid/clessidra.gif" border="0" >' + CNVAJAX ('../../' , 'Elaborazione in corso...' ) + '</td></tr></table>');
		
		document.new_document.action='../../AFLCommon/FolderGeneric/Command/Evaluate/UpdateCriteriTecnici.asp';
  	document.new_document.target='winCriteri';
  	document.new_document.submit();  
		
		
		/*
		var QuizForm2 = getNewSubmitForm();
		var lIdMsg = getObj('lIdMsgPar').value ;
    var lISubType = getObj('iSubType').value ;
    var lIdmp = getObj('IdMarketPlace').value ;
    createNewFormElement(QuizForm2, "lIdMsg",  lIdMsg );
    createNewFormElement(QuizForm2, "lISubType",  lISubType );
    createNewFormElement(QuizForm2, "lIdmp",  lIdmp );
    */
    
    //var QuizForm2 = document.new_document ;
    
    //if ( strField != '' ){
    
    //  var strDesc = GetDescriptionforQuiz( strField ) ;
    //  createNewFormElement(QuizForm2, "Value_Quiz",  getObj(strField).value );
    //  createNewFormElement(QuizForm2, "Description_Quiz",  strDesc );
    //}
    
    //if ( Param != '' ){
    
    //  createNewFormElement(QuizForm2, "Param_Quiz",  Param );
    //}
    
    //if ( Param.indexOf('UpdateTecnica=YES', 0) < 0  ){
    
    //QuizForm2.action= '../../AFLCommon/FolderGeneric/Command/Evaluate/UpdateCriteriTecnici.asp' ;
    //QuizForm2.target= 'winCriteri' ;
    //QuizForm2.submit();  
      
    //}else{
      
    //  document.new_document.action='../../AFLCommon/FolderGeneric/Command/Evaluate/UpdateCriteriTecnici.asp';
  	//	document.new_document.target='winCriteri';
  	//	document.new_document.submit();  
  	//QuizForm2.action='../../AFLCommon/FolderGeneric/Command/Evaluate/UpdateCriteriTecnici.asp?UpdateTecnica=YES';
  		
    //}
    
        
    
  }
	
	
	//disabilita le righe dei criteri che non hanno l'attributo Punteggio perchè sono relative a criteri a QUIZ
	function DisableCriteriQuiz(){
    
    var strNameControl='CRITERI_griglia' ;
    var nPosFormula=GetColumnPositionInGrid('TechnicalExpression',strNameControl);
    var nPosDesc=GetColumnPositionInGrid('DescrAttach',strNameControl);
    var nPosScore =GetColumnPositionInGrid('Score',strNameControl);
    
    var objRow=getObj('NumProduct_'+ strNameControl);
    var nNumRow=Number(objRow.value);
    var nIndRrow;
    var strValueFormula;
    var objCell;
    
    
    
    var strCeck = eval('document.new_document.' + strNameControl + '_seleziona_articoli');
    var len; 
    
    try{
        len = strCeck.length;
        
        for ( nIndRrow=1; nIndRrow<=nNumRow; nIndRrow++){	
          
          strValueFormula=getObj(strNameControl + '_' + nIndRrow + '_' + nPosFormula ).value;
          
          if ( strValueFormula != '' && strValueFormula.indexOf('Punteggio', 0) < 0 ){
            
            //nascondo ilcheckbox
            //TECNICA_griglia_seleziona_articoli
            if (len != null){
              strCeck[nIndRrow-1].style.display='none';
            }
            else{
              strCeck.style.display='none';
            }
            //nascondo la textarea della descrizione
            getObj( strNameControl + '_' + nIndRrow + '_' + nPosDesc ).style.display='none';
            //creo una label per la descrizione
            objCell = getObj( 'cell_' + strNameControl + '_' + nIndRrow + '_' + nPosDesc );
            var newLabel = document.createElement('label');
            newLabel.innerHTML = getObj( strNameControl + '_' + nIndRrow + '_' + nPosDesc ).value;
            objCell.appendChild(newLabel);
            
            //nascondo il campo visuale editabile dello Score
            getObj( 'Vis_' + strNameControl + '_' + nIndRrow + '_' + nPosScore ).style.display='none';
            var NewScore = document.createElement('<input style="width:110px;height:20" onFocus="Javascript:this.blur();" type="text" class="MoneyFieldLocked" name="xxxxx" value="' + getObj( 'Vis_' + strNameControl + '_' + nIndRrow + '_' + nPosScore ).value + '">');   
            objCell = getObj( 'cell_' + strNameControl + '_' + nIndRrow + '_' + nPosScore );
            objCell.appendChild(NewScore);
            
            //togliamo il bottone sulla formula
            getObj( 'btn_' + strNameControl + '_' + nIndRrow + '_' + nPosFormula ).style.display='none';
          }
      }
      
    }catch(e){
    }
    
  }
	
	//serve ad aggiornare la griglia dei criteri quando cambia la descrizione di un criterio a quiz nella busta TECNICA
	function UpdateDescCriterioQuiz( ){
    
    
    
    var nIndRrow;
    var strNomeCampo = this.name;
    var aInfo = strNomeCampo.split('_');
    
    nIndRrow = aInfo[2];
    
    var strFullNameArea='TECNICA_griglia' ;
    var nPosQuiz=GetColumnPositionInGrid('CriterioDiValutazioneQuiz',strFullNameArea);
    
    //se è impostata una formula allora innesco l'update
    if (getObj(strFullNameArea + '_' + nIndRrow + '_' + nPosQuiz ).value != '' ){
      
      //visualizzo loading  per segnalare elaborazione in corso  
      getObj('INFO_PROCESS').style.display='';
      
      //innesco pagina per aggiornare la griglia TECNICA in sessione
      const_width=300;
  	  const_height=150;
  	  sinistra=(screen.width-const_width)/2;
  	  alto=(screen.height-const_height)/2;
      
      var Path='../../ctl_library/';
      
      winCriteri=window.open('','winCriteri','toolbar=no,location=no,directories=no,status=yes,menubar=no,resizable=yes,copyhistory=no,scrollbars=no,width='+const_width+',height='+const_height+',left='+sinistra+',top='+alto+',screenX='+sinistra+',screenY='+alto+'');
      winCriteri.document.write('<link rel="stylesheet" href="' + Path + 'Themes/MsgBox.css" type="text/css">');
  		winCriteri.document.write('<title>' + CNVAJAX ('../../' , 'Aggiornamento Criteri tecnici' ) + '</title>');
  		winCriteri.document.write('<table class="INFO_BOX" cellpadding=0 cellspacing=0><tr><td align=center class=caption>' + CNVAJAX ('../../' , 'Attenzione' ) + '</td></tr>');
  		winCriteri.document.write('<tr><td class=elaborazione><img src="' + Path + 'images/grid/clessidra.gif" border="0" >' + CNVAJAX ('../../' , 'Elaborazione in corso...' ) + '</td></tr></table>');
  	  document.new_document.action='../../AFLCommon/FolderGeneric/Command/Evaluate/UpdateCriteriTecnici.asp';
  		document.new_document.target='winCriteri';
  		document.new_document.submit();  
  		
	  }
	  
  }
	
	
	//setta evento onchange sulla desc della griglia TECNICA in caso di Quiz
	function SetOnChangeDescTecnicaForQuiz( ){
	 
	  var strFullNameArea='TECNICA_griglia' ; 
    var strAttribTecnica = getObj('DZTNOME_' + strFullNameArea ).value;
    if ( strAttribTecnica.indexOf('CriterioDiValutazioneQuiz', 0) >= 0 ){
      
        var nPosDesc=GetColumnPositionInGrid('DescrAttach',strFullNameArea);
        var objRow=getObj('NumProduct_'+ strFullNameArea);
        var nNumRow=Number(objRow.value);
        var nIndRrow;
        for ( nIndRrow=1; nIndRrow<=nNumRow; nIndRrow++){	
    
          getObj(strFullNameArea + '_' + nIndRrow + '_' + nPosDesc ).onchange = UpdateDescCriterioQuiz ;
          
        }
    }
        
	}
	
  function getNewSubmitForm(){
    var submitForm = document.createElement("FORM");
    document.body.appendChild(submitForm);
    submitForm.method = "POST";
    return submitForm;
  }

  //helper function to add elements to the form
  function createNewFormElement(inputForm, elementName, elementValue){
    var newElement = document.createElement("<input name='"+elementName+"' type='hidden'>");
    inputForm.appendChild(newElement);
    newElement.value = elementValue;
    return newElement;
  }
  
  
  //NASCONDE LA COLONNA VALORE OFFERTO DELLA BUSTA ECONOMICA
  function HideValoreOffertoBustaEconomica(){
      
      try{
        ShowCol( 'ECONOMICA_griglia' , 'PrzUnOfferta' , 'none' );
      }catch(e){}
      
  }
  
  
  
  //CONTROLLA che la somma degli importi base asta sulla sezione 'busta economica' deve essere congruente
	//con 'importo base asta' presente in testata
  function CheckImportoBaseAsta(){
    
    var nomeCompletoGriglia = 'ECONOMICA_griglia';
    var nIndRrow;
    var objRow=getObj('NumProduct_'+ nomeCompletoGriglia); 
    var nNumRow=Number(objRow.value);
    var totPrz = 0.0;
    var colQTOrd;
    var objvalueQT;
    var objvalueQTVis;
    
    var colPos = GetColumnPositionInGrid('PrzBaseAsta',nomeCompletoGriglia);
    
    if ( colPos == -1 )
      return 0;
    
    colQTOrd =GetColumnPositionInGrid('CARQuantitaDaOrdinare',nomeCompletoGriglia);
    
    if (nNumRow > 0)
    {
      for (nIndRrow=1;nIndRrow<=nNumRow;nIndRrow++)
      {
      	try
      	{
      		
      		var campoN = getObj(nomeCompletoGriglia + '_' + nIndRrow + '_' + colPos);
      		
      		if (campoN.value == '' || parseFloat(campoN.value) <= 0 ){
            return -2;
          }
      		
      		//se è visibile CARQuantitaDaOrdinare moltipli per PrzBaseAsta
      		if ( colQTOrd != -1 ){
      			
      			objvalueQTVis = getObj( 'Vis_' + nomeCompletoGriglia + '_' + nIndRrow + '_' + colQTOrd );
      			
      			if (objvalueQTVis != null){
      				objvalueQT = getObj( nomeCompletoGriglia + '_' + nIndRrow + '_' + colQTOrd );  
      				totPrz = totPrz + ( parseFloat(campoN.value) * parseFloat(objvalueQT.value) );
      			}else
      			totPrz = totPrz + parseFloat(campoN.value);
      			
      			}else{
      			totPrz = totPrz + parseFloat(campoN.value);
      		}  
      	}
      	catch(e)
      	{
      		totPrz = getObj('ImportoBaseAsta2').value;
      		break;
      	}
      }
    }
    //alert(parseFloat(getObj('ImportoBaseAsta2').value));
    //alert(parseFloat(totPrz));
    
    if ( getObj('ImportoBaseAsta2').value != '' && getObj('ImportoBaseAsta2').value > 0 && parseFloat(getObj('ImportoBaseAsta2').value) != parseFloat(totPrz))
      return -1;
    
    return 0;
    
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
        try{
          var objRUPVisual = getObj( 'elemento1_InformazioniTecniche_comune_' + get_IdDztFromDztNome_AreaOfid('InformazioniTecniche_comune','R.U.P') );
        	objRUPVisual.style.display='none';
	      }catch(e){}
        
       
        
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
  
  //controlla che se ci sono criteri a quiz nella busta tecnica siano compilati
  function CheckCriteriQuizCompiled(){
    
    var strFullNameArea='TECNICA_griglia' ; 
    var strAttribTecnica = getObj('DZTNOME_' + strFullNameArea ).value;
    if ( strAttribTecnica.indexOf('CriterioDiValutazioneQuiz', 0) >= 0 ){
      
        var nPos=GetColumnPositionInGrid('CriterioDiValutazioneQuiz',strFullNameArea);
        var objRow=getObj('NumProduct_'+ strFullNameArea);
        var nNumRow=Number(objRow.value);
        var nIndRrow;
        
        for ( nIndRrow=1; nIndRrow<=nNumRow; nIndRrow++){	
          
          getObj('cell_' + strFullNameArea + '_' + nIndRrow +'_'+ nPos).className ='Cell1GridProducts1';
          
          if ( getObj(strFullNameArea + '_' + nIndRrow + '_' + nPos ).value == ''){
              //setClassName( getObj('cell_' + strFullNameArea + '_' + nIndRrow +'_'+ nPos), 'Value_Obblig');
              getObj('cell_' + strFullNameArea + '_' + nIndRrow +'_'+ nPos).className ='Value_Obblig';
              return false;
          } 
          
        }
    }
    
    return true;
    
  }
  
  
  
  //se esiste controlla che il valore relativo alla riga importo soggetto  a ribasso coincide con importobaseasta2 in copertina
  function CheckImportoBaseAstaInfTecniche(){
    
    var strFullNameArea = 'InformazioniTecniche_griglia'
    var objRow=getObj('NumProduct_'+ strFullNameArea); 
    var nNumRow=Number(objRow.value);
    var nIndRrow;
    
    
    var nPos=GetColumnPositionInGrid('DescrImportiVari',strFullNameArea);
    var nPos1=GetColumnPositionInGrid('ImportiVari',strFullNameArea);
    var strValueImporto='';
    if ( nNumRow > 0 ){
      
      for ( nIndRrow=1; nIndRrow<=nNumRow; nIndRrow++){	
        
        if ( getObj(strFullNameArea + '_' + nIndRrow + '_' + nPos ).value == '01' ){
          
            strValueImporto = getObj(strFullNameArea + '_' + nIndRrow + '_' + nPos1 ).value ;
            break;
        }
      
      }
      //alert(parseFloat(strValueImporto));
      
      if ( parseFloat(getObj('ImportoBaseAsta2').value) != parseFloat(strValueImporto)  )
        return false;
    }
    
    return true;
    
    
  }
  
  //nascondo attributi a prescindere
  function HideAttrib(){
    
    //nascondo fasegara
    getObj('lblFaseGara').style.display='none';
    getObj('FaseGara').style.display='none';
    
    try{
      getObj('FaseGara_vis').style.display='none';
    }catch(e){
    }
    
    //nascondo comandi area coumne sezione economica
    try{
      getObj('command_ECONOMICA_comune').style.display='none';
    }catch(e){
    }
    
    //nascondo valore offerta e Valore Offerta in Lettere
    getObj('ECONOMICA_comune').style.display='none';
    
    
    //se rettifica = no nascondo griglia avvisi di rettifica
    var Rettifica;
    Rettifica='no';
    try{ 
      Rettifica = getObj('Rettifica').value;
    }
    catch(e){}
    
    if ( Rettifica == 'no'){
		  //nascondo griglia rettifica
  	  getObj('caption_BANDO_rettifiche').style.display='none';
      getObj('BANDO_rettifiche').style.display='none';
  	  try{
  		  getObj('command_BANDO_rettifiche').style.display='none';
  	  }catch(e){}
	  }
    
  }
  
 //setta gli attributi in fnuzione di tipoappalto
  function SetAttributiFromTipoAppalto(){
    
    //eseguo vecchio onchange dell'attributo
    try{
        Old_tipoappalto_onchange();
    }catch(e){    
    }
    
    if ( getObj('CriterioAggiudicazioneGara').value != PDA_OffertaVantaggiosa ){
    
      var valTipoAppalto = getObj('tipoappalto').value;
      
      if (valTipoAppalto != ''){
        if ( valTipoAppalto == tipoappalto_LavoriPubblici )
          getObj('OffAnomale').value = PDA_OffAnomaleAutomatica ;
        else    
          getObj('OffAnomale').value = PDA_OffAnomaleValutazione ;
      }
    
    }else{
      
      getObj('OffAnomale').value = PDA_OffAnomaleValutazione ;
    
    }
    
  }
  
  
  //NASCONDE LE BUSTE A SECONDA DI PROCEDURAGARA E TIPOBANDO
  function HideBusteFromProgeduraGara_TipoBando(){
    
    //in caso di RDI nascondo la sezione ECONOMICA e sezione TECNICA
    if  ( getObj('ProceduraGara').value == ProceduraRDI ) {
      
      hObjSection = getObj( 'TECNICA_Hide' );                   
      hObjSection.value = 1 ;                                               
      
      hObjSection = getObj( 'ECONOMICA_Hide' );                   
      hObjSection.value = 1 ;                                               
    
    } 
    
    
    //SE (ProceduraGara=RISTRETTA e TipoBando=BANDO) oppure (ProceduraGara=ECONOMIA/MARKETPLACE e TipoBando=BANDO)
    //nascondo le sezioni: INFORMAZIONI TECNICHE,ECONOMICA,TECNICA,CRITERI e setto Divisione_lotti a no
    if  ( ( getObj('ProceduraGara').value == ProceduraRistretta && getObj('TipoBando').value == Bando ) || ( ( getObj('ProceduraGara').value == ProceduraNegoziata || getObj('ProceduraGara').value == ProceduraEconomia ) && getObj('TipoBando').value == Avviso ) ) {
      
      hObjSection = getObj( 'InformazioniTecniche_Hide' );                   
      hObjSection.value = 1 ;                                               
      
      hObjSection = getObj( 'TECNICA_Hide' );                   
      hObjSection.value = 1 ;                                               
      
      hObjSection = getObj( 'ECONOMICA_Hide' );                   
      hObjSection.value = 1 ;                                               
      
      getObj('Divisione_lotti').value='0';
      
      hObjSection = getObj( 'GestioneLotti_Hide' );                  
      hObjSection.value = 1 ;  
      
      hObjSection = getObj( 'MicroLotti_Hide' );                   
      hObjSection.value = 1 ;  
      
      hObjSection = getObj( 'OFFERTAECONOMICAMICROLOTTI_Hide' );                   
      hObjSection.value = 1 ;  
      
      
      hObjSection = getObj( 'CRITERI_Hide' );                   
      hObjSection.value = 1 ;     
      
      
    }else{
      
      hObjSection = getObj( 'InformazioniTecniche_Hide' );                   
      hObjSection.value = 0 ;                                               
           
      hObjSection = getObj( 'CRITERI_Hide' );                   
      hObjSection.value = 0 ;
      
      hObjSection = getObj( 'ECONOMICA_Hide' );                   
      hObjSection.value = 0 ;                                               
      
      
    }
     
    
    //SE (ProceduraGara=ECONOMIA/MARKETPLACE e TipoBando=BANDO) nascondo anche la busta di documentazione
    if ( ( getObj('ProceduraGara').value == ProceduraNegoziata || getObj('ProceduraGara').value == ProceduraEconomia ) && getObj('TipoBando').value == Avviso ){
      
      hObjSection = getObj( 'DOCUMENTAZIONE_Hide' );                   
      hObjSection.value = 1 ;     
      
    }else{
      
      hObjSection = getObj( 'DOCUMENTAZIONE_Hide' );                   
      hObjSection.value = 0 ;     
      
    }
    
    
    //SE PROCEDURA ECONOMIA/MARKETPLACE e TIPBANDO=INVITO NASCONDO ALTRO INDIRIZZO WEB NELLE INF. TECNICHE
    var objLabelSitoWeb = getObj( 'spn_elemento_InformazioniTecniche_2comune_' + get_IdDztFromDztNome_AreaOfid('InformazioniTecniche_2comune','AltroSitoWeb') );
    var objSitoWeb = getObj( 'elemento_InformazioniTecniche_2comune_' + get_IdDztFromDztNome_AreaOfid('InformazioniTecniche_2comune','AltroSitoWeb') );
    var objSitoWebVisual = getObj( 'elemento1_InformazioniTecniche_2comune_' + get_IdDztFromDztNome_AreaOfid('InformazioniTecniche_2comune','AltroSitoWeb') );
    
    if ( ( getObj('ProceduraGara').value == ProceduraNegoziata || getObj('ProceduraGara').value == ProceduraEconomia ) && getObj('TipoBando').value == Invito ){
      
      objLabelSitoWeb.style.display='none';
      objSitoWeb.style.display='none';
      try{objSitoWebVisual.style.display='none';}catch(e){}	   
      
    }else{
      
      objLabelSitoWeb.style.display='';
      objSitoWeb.style.display='';
      try{objSitoWebVisual.style.display='';}catch(e){}	   
      
    }
        
    DrawLabel( LinkAttivo );   
    
  }
   //nasconde l'allegato nella Busta Economica
  function HideAllegatoBustaEconomica(){
   
   try{
        ShowCol( 'DOCUMENTAZIONE_griglia' , 'Attach' , 'none' );
   }catch(e){}
	 
  }
  
  
  //verifico che se presenti gli attributi CarQuantitaDaOrdinare,Peso,Coefficiente
  //siano maggiori di 0; restituisce il nome dell'attributo che non verifica il controllo
  function CheckAttributiBustaEconomica(){
    
    var nomeCompletoGriglia = 'ECONOMICA_griglia';
    var nIndRrow;
    var objRow=getObj('NumProduct_'+ nomeCompletoGriglia); 
    var nNumRow=Number(objRow.value);  
    
    var colQT = GetColumnPositionInGrid('CarQuantitaDaOrdinare',nomeCompletoGriglia);
    var colPeso = GetColumnPositionInGrid('Peso',nomeCompletoGriglia);
    var colCoeff = GetColumnPositionInGrid('Coefficiente',nomeCompletoGriglia);
    
    var objVis;
    var objTec;
    
    
    if ( colQT == -1 && colPeso == -1 && colCoeff == -1)
      return '';
    
    for (nIndRrow=1;nIndRrow<=nNumRow;nIndRrow++){
      
      //controllo CarQuantitaDaOrdinare
      if ( colQT != -1 ){
        objVis = getObj( 'Vis_' + nomeCompletoGriglia + '_' + nIndRrow + '_' + colQT );
  			if (objVis != null){
  			  objTec = getObj( nomeCompletoGriglia + '_' + nIndRrow + '_' + colQT );  
  			  if ( objTec.value=='' || parseFloat(objTec.value)<=0 )
  			    return 'CarQuantitaDaOrdinare';
  			}	
      }
      				
      //controllo Peso
      if ( colPeso != -1 ){
       	objVis = getObj( 'Vis_' + nomeCompletoGriglia + '_' + nIndRrow + '_' + colPeso );
  			if (objVis != null){
  			  objTec = getObj( nomeCompletoGriglia + '_' + nIndRrow + '_' + colPeso );  
  				if ( objTec.value=='' || parseFloat(objTec.value)<=0 )
  				  return 'Peso';
  			}	
      }
      
      
      //controllo Coefficiente
      if ( colCoeff != -1 ){
      	objVis = getObj( 'Vis_' + nomeCompletoGriglia + '_' + nIndRrow + '_' + colCoeff );
  			if (objVis != null){
  				objTec = getObj( nomeCompletoGriglia + '_' + nIndRrow + '_' + colCoeff );  
  				if ( objTec.value=='' || parseFloat(objTec.value)<=0 )
  				  return 'Coefficiente';
  			}	
      }
      
    }
    
    return '';
    
  }
  
  
  
  //controlla se disabilitare i comandi PDA/PREQUALIFICA
  function DisablePDA_Prequalifica(){
    
    //pda classica
    //OPEN_CREATE_12 LNK_OPEN_CREATE_12
    
    //pda microlotti
    //OPENURL_7 LNK_OPENURL_7
    
    //prequalifica
    //OPEN_CREATE_9 LNK_OPEN_CREATE_9
    
    //strresult=0@@@1@@@0 (PDA###PREQUALIFICA###PDAMICROLOTTI)
    ajax = GetXMLHttpRequest(); 
  
  	if(ajax){
  				 
  		  ajax.open("GET", '../../ctl_library/functions/Check_PDA_Prequalifica.asp?DOCUMENT=DOCUMENTO_GENERICO&IDDOC=' + getObj('lIdMsgPar').value , false);
  	 		 
  			ajax.send(null);
  			
  			if(ajax.readyState == 4) {
  			
  				if(ajax.status == 200)
  				{
  				
  				  if ( ajax.responseText != '' ) {
  				    var strresult = ajax.responseText;
  				    //alert(strresult);              
  				    
  				    var ainfo=strresult.split('@@@');
  				    
  				    if ( ainfo[0] == '0' ){
                //NASCONDO CREA PDA CLASSICO
                try{
                  getObj( 'OPEN_CREATE_12' ).style.display='none';
                  getObj( 'IMG_OPEN_CREATE_12' ).style.display='none';
                } catch(e){  
                  getObj( 'LNK_OPEN_CREATE_12' ).style.display='none'; 
                  getObj( 'IMG_OPEN_CREATE_12' ).style.display='none';
                }
              
              }
              
              if ( ainfo[1] == '0' ){
                //NASCONDO CREA PREQUALIFICA
                try{
                  getObj( 'OPEN_CREATE_9' ).style.display='none';
                  getObj( 'IMG_OPEN_CREATE_9' ).style.display='none';
                } catch(e){  
                  getObj( 'LNK_OPEN_CREATE_9' ).style.display='none'; 
                  getObj( 'IMG_OPEN_CREATE_9' ).style.display='none';
                }
              }
              
              if ( ainfo[2] == '0' ){
                //NASCONDO PDA MICROLOTTI
                try{
                  getObj( 'OPENURL_7' ).style.display='none'; 
                  getObj( 'IMG_OPENURL_7' ).style.display='none';
                } catch(e){ 
                  getObj( 'LNK_OPENURL_7' ).style.display='none'; 
                  getObj( 'IMG_OPENURL_7' ).style.display='none';
                }
  				    }
  				    
  				  }
  				}
  			}
  
  	}
    
  }
  
  
//Gestione Sezione Destinatari:
//se doc salvato visualizzo nuovo viewer altrimenti vecchia griglia
function HandleSezioneDestinatari(){
  
  //se ho la nuova area dei destinatari
  if ( getObj('iframe_CompanyDes_ViewerDestinatari') != null ){
  
    //se si tratta di un INVITO
    if ( getObj('TipoBando').value == Invito ){
      
        
      //se procedura Negoziata
      if ( getObj('ProceduraGara').value == ProceduraNegoziata ){
       
        //se documento nuovo/salvato visualizzo nuovo viewer altrimenti vecchio
        if ( getObj('Stato').value == '0' ||  getObj('Stato').value == '1' ){
          
          //nascondo il comando esporta in excel
          try{getObj('CompanyDes_GridDest_Esporta in Excel1').style.display='none'; }catch(e){}
          
          //se senza giro avviso nascondo la vecchia area
          if ( getObj('ProtocolBG').value == ''){
            getObj( 'CompanyDes_GridDest' ).style.display='none'; 
          }
          
          //carico nella nuov aarea il nuovo viewer 
          var IdHeader = getObj('lIdMsgPar').value ;
          var strURL = '../../DASHBOARD/Viewer.asp?PATHTOOLBAR=../customdoc/&JScript=&Exit=&Table=DESTINATARI_RICERCA_OE&OWNER=&IDENTITY=IdAzi&TOOLBAR=DESTINATARI_RICERCA_TOOLBAR&DOCUMENT=&AreaAdd=no&CaptionNoML=no&Caption=&Height=0,100*,210&numRowForPag=25&Sort=aziragionesociale&SortOrder=asc&ACTIVESEL=1&AreaFiltroWin=0&AreaFiltro=no&';  
          var  FilterHide = 'FilterHide=linkedDoc=' + IdHeader ;
          strURL = strURL + FilterHide ;
          //strURL = strURL + '&ModGriglia=';
          getObj('iframe_CompanyDes_ViewerDestinatari').src = strURL;
           
        }else{  
          getObj( 'CompanyDes_ViewerDestinatari' ).style.display='none'; 
        }
          
      }
    }
  }
  
}
  
  
function RefreshContent(){
  
  if ( getObj('Stato').value == '2' )
  {
	self.location=self.location;
  }
  
  else
  //se ho la nuova area dei destinatari
  {
	  if ( getObj('iframe_CompanyDes_ViewerDestinatari') != null ){
	  
		if ( getObj('TipoBando').value == Invito && getObj('Stato').value != '2' ){
		
		  //ricarico il viewer dei destinatari
		  var IdHeader = getObj('lIdMsgPar').value
		  var strURL = '../../DASHBOARD/Viewer.asp?PATHTOOLBAR=../customdoc/&JScript=&Exit=&Table=DESTINATARI_RICERCA_OE&OWNER=&IDENTITY=IDROW&TOOLBAR=DESTINATARI_RICERCA_TOOLBAR&DOCUMENT=&AreaAdd=no&CaptionNoML=no&Caption=&Height=0,100*,210&numRowForPag=25&Sort=aziragionesociale&SortOrder=asc&ACTIVESEL=1&AreaFiltroWin=0&AreaFiltro=no&';  
		  var  FilterHide = 'FilterHide=linkedDoc=' + IdHeader ;
		  strURL = strURL + FilterHide ;
		  //strURL = strURL + '&ModGriglia=BANDO_GARA_DESTINATARI';
		  getObj('iframe_CompanyDes_ViewerDestinatari').src = strURL;
		  
		}
		
	  }
  }
}	
	
    
		
	

  
</script>

