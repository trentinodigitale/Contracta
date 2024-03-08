
<script language="javascript">
//Versione=1&data=2012-10-17&Attvita=39758&Nominativo=Francesco

   var PDA_CriterioPrezzobasso	= '15531';
   var PDA_OffertaVantaggiosa	= '15532';
      
   var PDA_CriterioFormulazioneOffertePrezzo		 = '15536';
   var PDA_CriterioFormulazioneOffertePercentuale = '15537';
      
   var PDA_OffAnomaleAutomatica	= '16309';
   var PDA_OffAnomaleValutazione	= '16310';
       
   var oldSend;

   function NewSend(){
   
   
		//innesco i controlli base di tipo CANSEND del documento
		if  ( ! SENDBASE())
		return;
		
		
		
		//se devo inserire i destinatari lo controllo dando un messaggio 
		if ( nNumCurrCompany_CompanyDes == 0 ){
		
		alert(CNV ('../../' , 'Inserire almeno un Destinatario' ));
		DrawLabel('1'); 
		FUNC_CompanyDes();
		return;
		}  
   
      //criterio di aggiudicazione = AL PREZZO + BASSO  e criterio di formulazione offerta= importo 
      //allora importo a base d'asta è obbligatorio
      var CriterioAggiudicazioneGara = getObj('CriterioAggiudicazioneGara').value;
      //alert (CriterioAggiudicazioneGara);
      var CriterioFormulazioneOfferte = getObj('CriterioFormulazioneOfferte').value;
      if ( CriterioAggiudicazioneGara == PDA_CriterioPrezzobasso && CriterioFormulazioneOfferte == PDA_CriterioFormulazioneOffertePrezzo ) {
        
        var importobaseasta=getObj('ImportoBaseAsta2').value;
        if ( importobaseasta == '' || importobaseasta == '0'){
          
          alert('Il campo Importo Base Asta e\' obbligatorio.');
          getObj('Vis_ImportoBaseAsta2').focus();
          return;
          
        }
      }
      
      //se criterio=OFFERTA ECONOMICAMENTE + VANTAGGIOSA verificare che l'attributo
		  //OffAnomale=valutazione
		  try{
  		  var OffAnomale = getObj('OffAnomale').value;
  		  if ( CriterioAggiudicazioneGara == PDA_OffertaVantaggiosa && OffAnomale != PDA_OffAnomaleValutazione ) {
            
            alert('Il campo Offerte anomale deve essere settato a Valutazione.');
            getObj('OffAnomale').focus();
            return;       		  
            
  		  }
      }catch(e){
      }
      
      //se critrio offerta + vantaggiosa controllo che la somma dei MAX punteggi economico e tecnico sia=100
      if ( CriterioAggiudicazioneGara == PDA_OffertaVantaggiosa ){
          
          //recupero iddzt di PunteggioEconomico
          var ListAttrib = getObj('ListAttrib_CRITERI_comune').value;
          var ainfo = ListAttrib.split('#');
          for ( i=0; i < ainfo.length; i++ ){
							
							var InfoAttrib=ainfo[i];
							
							ainfo1=ainfo[i].split(';');
							
							if (ainfo1[0] == 'Punteggioeconomico'){
								
								var MAXPuntECO = parseFloat ( getObj('elemento_CRITERI_comune_' + ainfo1[1] ).value ) ; 
								
						  }
          }  		
                      
          //alert(MAXPuntECO);
          
          //faccio la somma deipunt tecnici della griglia
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
          
          //alert(MAXPuntTEC);
          //alert(MAXPuntTEC + MAXPuntECO);
          if ( MAXPuntTEC + MAXPuntECO != 100 ){
            alert('La somma del MAX Punteggio Economico e del MAX Punteggio Tecnico deve essere 100.');
            return;
          }
          
      }
         
	    oldSend('SEND,APPROVAZIONE');
	   
   }	

   //SEND = NewSend ;	
   
   //conservo la lista completa delle opzioni
   var ObjCriterioDiValutazioneCompleta;
   var Old_CriterioAggiudicazioneGara_onchange;
   var Old_CriterioFormulazioneOfferte_onchange;
   var selValueCriterioValutazione ;
   
   window.onload = SetOnChangeAttributi ;
   
   
   function SetCriterioValutazione(){
      
      try{
        Old_CriterioAggiudicazioneGara_onchange();
        Old_CriterioFormulazioneOfferte_onchange();
      }catch(e){
        
      }
      //se CriterioAggiudicazioneGara=Offerta Economicamnete + vantagg. in CriterioValutazione ci sarà la voce "Con Coefficienti"
      if ( getObj('CriterioAggiudicazioneGara').value != PDA_OffertaVantaggiosa )
           rimuovivoce ( 'coefficienti' );
      else
           aggiungivoce ( 'coefficienti' );
      
      //se CriterioFormulazioneEconomica=Prezzo ci sarà  la voce "Miglior Prezzo"
      
      if ( getObj('CriterioFormulazioneOfferte').value == PDA_CriterioFormulazioneOffertePrezzo )
          aggiungivoce ( 'migliorprezzo' );
      else
           rimuovivoce ( 'migliorprezzo' );
      
      // se CriterioFormulazioneEconomica=Percentuale ci sarà  la voce "Miglior Percentuale di Sconto"	
      if ( getObj('CriterioFormulazioneOfferte').value == PDA_CriterioFormulazioneOffertePercentuale )
          aggiungivoce ( 'migliorsconto' );
      else
          rimuovivoce ( 'migliorsconto' );
      
   }
   
   
   function SetOnChangeAttributi(){
   
	  //controllo se rimappare la SEND in funzione del ciclo di approvazione

	
	if (getObj('AdvancedState').value!='4' && getObj('Stato').value!='2' )
	{
	
	    oldSend=ExecDocProcess;
		ExecDocProcess = NewSend;
	}

		
      if ( getObj('Stato').value == '0' || ( getObj('Stato').value == '1' && getObj('AdvancedState').value != '4' && getObj('AdvancedState').value != '5' ) ){
      
       
        selValueCriterioValutazione = getObj('CriterioDiValutazione').value ;
      
        CopiaListaCompleta();
         
        svuota();
      
        aggiungivoce ( 'altro' );
      
        
        Old_CriterioAggiudicazioneGara_onchange = getObj('CriterioAggiudicazioneGara').onchange;      
        getObj('CriterioAggiudicazioneGara').onchange = SetCriterioValutazione ;
        
        Old_CriterioFormulazioneOfferte_onchange = getObj('CriterioFormulazioneOfferte').onchange;
        getObj('CriterioFormulazioneOfferte').onchange = SetCriterioValutazione ;
        
      
      
        SetCriterioValutazione();
      
        //associo azione onchange per preimpostare la formula se CriterioDiValutazione  <> altro
        getObj('CriterioDiValutazione').onchange = SetFormula ;
      
        //associo azione onchange per preimpostare il coefficiente giusto se la formula è allegatop
        getObj('CoefficienteX').onchange = SetFormula ;
      
      }
      
   }
   
   
	function CopiaListaCompleta(){
    
    ObjCriterioDiValutazioneCompleta = document.createElement("select");
    
    num_option=getObj('CriterioDiValutazione').options.length;
    
    
    
    for(a=0;a<num_option;a++){
    
      var newSelectOption = document.createElement('option');
      newSelectOption.setAttribute('value', getObj('CriterioDiValutazione').options[a].value);
      textForOption=document.createTextNode(getObj('CriterioDiValutazione').options[a].innerHTML );
      newSelectOption.appendChild(textForOption);
      
  		ObjCriterioDiValutazioneCompleta.appendChild ( newSelectOption );
		}
       
  }
  
  
  function aggiungivoce( value_selezionato ){
  	
    if (ObjCriterioDiValutazioneCompleta.options.length >= 0 ){
		 
      //recupero il nodo da aggiungere dalla lista completa 
		  for(a=0;a<ObjCriterioDiValutazioneCompleta.options.length;a++){
				if(ObjCriterioDiValutazioneCompleta.options[a].value == value_selezionato ){
					value_selezionato = ObjCriterioDiValutazioneCompleta.options[a].value;
			    testo_selezionato = ObjCriterioDiValutazioneCompleta.options[a].innerHTML;
			    break;
				}
			}
			
			//controllo che nn è già presente nella lista corrente
			num_option=getObj('CriterioDiValutazione').options.length; 
    	duplicato=0;
		  for(a=0;a<num_option;a++){
				if(getObj('CriterioDiValutazione').options[a].value == value_selezionato){
					duplicato=1;
					break;
				}
			}
			
			if(duplicato==0){
				getObj('CriterioDiValutazione').options[num_option]=new Option('',escape(value_selezionato),false,false);
				getObj('CriterioDiValutazione').options[num_option].innerHTML = testo_selezionato;
			}
    
    }
    
	}
	
	
	
	function rimuovivoce( value_selezionato ){
		
		num_option=getObj('CriterioDiValutazione').options.length;
		
    for(a=0;a<num_option;a++){
  		if(getObj('CriterioDiValutazione').options[a].value == value_selezionato){
  			getObj('CriterioDiValutazione').options[a]=null;
  			break;
  		}
		}
		
	}


  
	function svuota(){
		num_option=getObj('CriterioDiValutazione').options.length;
		for(a=num_option-1 ; a>=0 ;a--){
		  if ( getObj('CriterioDiValutazione').options[a].value != selValueCriterioValutazione )
			   getObj('CriterioDiValutazione').options[a]=null;
		}
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
    for ( i=0; i < ainfo.length; i++ ){
				
				InfoAttrib=ainfo[i];
				
				ainfo1=ainfo[i].split(';');
				
				if (ainfo1[0] == 'EconomicExpression'){
					
					iddztEconomicExpression = ainfo1[1];
					break;
					
			  }
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
      getObj('btn_elemento_CRITERI_comune_' + iddztEconomicExpression ).style.display='none';
      
   }else {
   
      getObj('elemento_CRITERI_comune_' + iddztEconomicExpression ).value = '' ;
      getObj('label_elemento_CRITERI_comune_' + iddztEconomicExpression ).innerHTML = '' ;
      getObj('btn_elemento_CRITERI_comune_' + iddztEconomicExpression ).style.display='';
  }
    
  }
	

	
</script>

