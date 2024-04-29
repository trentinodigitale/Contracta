
<script language="javascript"> 

//dominio assoc. a CriterioAggiudicazioneGara
var PDA_CriterioPrezzobasso	= '15531';
var PDA_OffertaVantaggiosa	= '15532';
var PDA_CriterioPrezzoAlto	= '16291';
   

   window.onload = InitPDA ;
   
   function InitPDA() {
   
    	
      //Nascondo vecchio campo incaricato a partire da una certa data
      HideIncaricatoAperto();
      
      
      //Nascondo la commissione appropriata
      HideCommissione();
      
      
      //Se documento non editabile setta nella colonna del radio button funzione per aprire Modifica Partecipante
      SetModificaPartecipante();
      
      //aggiorno statofirme e presenzaAvvalimenti
      GetStatoFirmeAvvalimenti();
      
      
      //disabilita comandi se bando REVOCATO
      DisableComandiBandoRevocato();
      
      
      //nasconde Comandi Aggiudicataria Invitati se non Invito
      HideComandiAggiudicataria();
        
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
    
    
      if ( strdata > '2012-11-21T00:00:00')
        nHide=1;
      
      if (getObj('Stato').value == '0' || nHide == 1 ){
        
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
        
        
        //nascondo vecchio campo Atto Nomina delle commissioni
        try{
          var objLabelRUP = getObj( 'spn_elemento_Commissione_comune_' + get_IdDztFromDztNome_AreaOfid('Commissione_comune','AttoNomina') );
          objLabelRUP.style.display='none';
          var objRUP = getObj( 'elemento_Commissione_comune_' + get_IdDztFromDztNome_AreaOfid('Commissione_comune','AttoNomina') );
          objRUP.style.display='none';
          
          objLabelRUP = getObj( 'spn_elemento_Commissione_AttoNominaAgg_' + get_IdDztFromDztNome_AreaOfid('Commissione_AttoNominaAgg','AttoNominaGiudicatrice') );
          objLabelRUP.style.display='none';
          objRUP = getObj( 'elemento_Commissione_AttoNominaAgg_' + get_IdDztFromDztNome_AreaOfid('Commissione_AttoNominaAgg','AttoNominaGiudicatrice') );
          objRUP.style.display='none';
          
        }catch(e){alert(e);}
        
        
        //nascondo vecchie aree griglia 
        try{
          getObj('command_Commissione_griglia').style.display='none';
          getObj('Commissione_griglia').style.display='none';
          
          getObj('command_Commissione_CommissioneAgg').style.display='none';
          getObj('Commissione_CommissioneAgg').style.display='none';
          
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
        
        
        //nascondo nuove aree griglia 
        try{
          getObj('command_Commissione_CommissioneGara').style.display='none';
          getObj('Commissione_CommissioneGara').style.display='none';
          
          getObj('command_Commissione_Commissione2Agg').style.display='none';
          getObj('Commissione_Commissione2Agg').style.display='none';
          
        }catch(e){}
        
        
        
      }
    
    }catch(e){
    }

    
    
  }
  
  
  //nascionde la commissione appropriata
function HideCommissione(){
    
    //NASCONDO COMMISSIONE GIUDICATRICE SE CriterioAggiudicazioneGara <> Offerta economic. più vantaggiosa
    if ( getObj('CriterioAggiudicazioneGara').value != PDA_OffertaVantaggiosa ){ 
      
      try{
        getObj('caption_Commissione_AttoNominaAgg').style.display='none';
        getObj('Commissione_AttoNominaAgg').style.display='none';
        getObj('command_Commissione_CommissioneAgg').style.display='none';
        getObj('Commissione_CommissioneAgg').style.display='none';
        
        //nascondo griglia per gli atti agg
        getObj('command_Commissione_2grigliaattonominaagg').style.display='none';
        getObj('Commissione_2grigliaattonominaagg').style.display='none';
        
        //nascondo griglia per la commissione per gli atti agg
        getObj('command_Commissione_Commissione2Agg').style.display='none';
        getObj('Commissione_Commissione2Agg').style.display='none';
        
      }catch(e){}
        
    }else{
      
      //carico il compilatore degli atti di gara
      //LoadCompilatoreAttiDiGara();
      
    
    }    
}
  
  
  
  
//esegue azioni custom sull'area COMMISSIONE GIUDICATRICE
/*
function CustomActionOnGrid( strFullAreaName ){
    
    
    //SE PRESENTE UNA SOLA RIGA ED E' VUOTA
    if ( ( strFullAreaName == 'Commissione_Commissione2Agg' ) && getObj('NumProduct_Commissione_Commissione2Agg').value == 1 ){
      
      var colPos = GetColumnPositionInGrid('UtenteCommissione','Commissione_Commissione2Agg');
      
      //if ( getObj( 'Commissione_Commissione2Agg_1_' + colPos ).value=='' ) {
      
        var strProtocolloBando=getObj('ProtocolloBando').value;
        
        ajax = GetXMLHttpRequest(); 
        if(ajax){
        		
            ajax.open("GET", '../../CustomDoc/Get_RUP_PDA.asp?ProtocolloBando=' + escape( strProtocolloBando ) , false);
        	  ajax.send(null);
            
            if(ajax.readyState == 4) {
              
              if(ajax.status == 200)
        	    {
        		    result =  ajax.responseText;
        		    
        		    if ( result != ''){
        		      var aInfo = result.split('###') 
                  //setto il compilatore
                  objNominativo = getObj( 'Commissione_Commissione2Agg_1_' + colPos );  
                  objNominativo.value = aInfo[1] ;
                  
                }
        		    
        	    }
            }
        }
  }
  
  
}


function LoadCompilatoreAttiDiGara(){

  //SE VUOTA CARICO NELLA COMMISSIONE GIUDICATRICE UNA RIGA CON IL COMPILATORE DEGLI ATTI DI GARA
  if ( getObj('NumProduct_Commissione_Commissione2Agg').value < 1 )
      //AGGIUNGO UNA RIGA ALLA COMMISSIONE GIUDICATRICE
      //INSERTARTICLE('5068','1','55','169','','Commissione_Commissione2Agg','Inserisci Riga','1');
      getObj('Commissione_Commissione2Agg_Prodotto/Inserisci allegato0').onclick();
}
*/



//setta funzione modifica partecipante nella colonna dei radiobutton che non serve
function SetModificaPartecipante(){
  
  
  if (getObj('Stato').value == '2'){
    
    //recupero numero righe griglia valutazione
    var nRow = getObj('NumProduct_Valutazione_griglia').value;
    
    var TitleModifica = CNV('../../' , 'Partecipanti Offerta' );
    
    var objCell;
    var lIdMsgPar;
    //cell_Valutazione_griglia_1_0
    for ( i=1; i <= nRow; i++ ){
      
      //recupero idmsg della riga
      lIdMsgPar = -1 ;
      lIdMsgPar = getObj('Valutazione_griglia_' + i + '_0').value;
      
      //aggiungo funzione alla riga 
      objCell = getObj('cell_Valutazione_griglia_' + i + '_0');
      //objCell.innerHTML = objCell.innerHTML + '<a title="' + TitleModifica + '" href="#" onclick="javascript:OPEN_PARTECIPANTI('+ lIdMsgPar + ');"><img border=0 src="../../images/General/LabelListFunctions/OpenPartecipanti_Light.gif"></a>';
      objCell.innerHTML = '&nbsp;<a title="' + TitleModifica + '" href="#" onclick="javascript:OPEN_PARTECIPANTI('+ lIdMsgPar + ');"><img border=0 src="../../images/General/LabelListFunctions/OpenPartecipanti_Light.gif"></a>&nbsp;';
		
      
    }
    
    
  
  }
  
}



//setta funcione per aprire documento OFFERTA_ALLEGATI
function SetOffertaAllegati(){

  //recupero numero righe griglia valutazione
  var nRow = getObj('NumProduct_Valutazione_griglia').value;
  
  var TitleModifica = CNV('../../' , 'Allegati Offerta' );
  
  var objCell;
  var lIdMsgPar;
  
  //recupero posizione colonna StatoFirme
  var colStatoFirme = GetColumnPositionInGrid('StatoFirme','Valutazione_griglia');
  
  //se esiste procedo
  if ( colStatoFirme != -1 ){
  
    for ( i=1; i <= nRow; i++ ){
      
      //recupero idmsg della riga
      lIdMsgPar = -1 ;
      lIdMsgPar = getObj('Valutazione_griglia_' + i + '_0').value;
      
      //aggiungo funzione alla riga 
      objCell = getObj('cell_Valutazione_griglia_' + i + '_' + colStatoFirme);
      //objCell.innerHTML = objCell.innerHTML + '<a title="' + TitleModifica + '" href="#" onclick="javascript:OPEN_PARTECIPANTI('+ lIdMsgPar + ');"><img border=0 src="../../images/General/LabelListFunctions/OpenPartecipanti_Light.gif"></a>';
      OldContent = objCell.innerHTML;
      objCell.innerHTML = '<a title="' + TitleModifica + '" href="#" onclick="javascript:ALLEGATI_OFFERTA('+ lIdMsgPar + ');">' +  OldContent + '</a>';
  	
      
    }
  }
    
}


//apre il documento che visualizza gli allegati di una offerta
function ALLEGATI_OFFERTA( lIdMsgParam ){
  
  	if (lIdMsgParam != '-1'){
	   					
			nValid=1;
			
			try{
			
				strIdMsgValid=document.new_document.strIdMsgValid.value;
				nValid=strIdMsgValid.search(',' + lIdMsgParam + ',');
			
			}catch(e){
			}
						
			if (nValid<0){
				alert('<% =CNVMPJS(lIdmp,"operazione non possibile messaggio invalidato") %>');
				
			}else{
				
				var IdMsgPDA = getObj('lIdMsgPar').value
				
				strUrl='../../ctl_library/functions/Open_Allegati_Offerta.asp?';
				
				strUrl=strUrl+'IDDOC='+lIdMsgParam;
				strUrl=strUrl+'&TYPEDOC=DOCUMENTOGENERICO';
				strUrl=strUrl+'&IDDOC_PDA='+IdMsgPDA;
				
				const_width=690;
				const_height=500;
				sinistra=(screen.width-const_width)/2;
				alto=(screen.height-const_height)/2;
				window.open(strUrl,'ALLEGATI_OFFERTA','toolbar=no,location=no,directories=no,status=<%=CONST_STATUS%>,menubar=no,resizable=yes,copyhistory=no,scrollbars=yes,width='+const_width+',height='+const_height+',left='+sinistra+',top='+alto+',screenX='+sinistra+',screenY='+alto+'');
			}

   }
}

//recupera le info per aggiornare le colonne StatoFirme  e PresenzaAvvalimenti
function GetStatoFirmeAvvalimenti(){
  
  var colStatoFirme = GetColumnPositionInGrid('StatoFirme','Valutazione_griglia');
 
  //se esiste procedo
  if ( colStatoFirme != -1 ){
    
    ajax = GetXMLHttpRequest(); 
    if(ajax){
    		
        ajax.open("GET", './Command/Evaluate/Get_StatoFirme_Avvalimenti.asp?IDDOC_PDA=' + getObj('lIdMsgPar').value , false);
    	  ajax.send(null);
        
        if(ajax.readyState == 4) {
          
          if(ajax.status == 200)
    	    {
    		    var result1 =  ajax.responseText;
            
    		    if ( result1 != '' ){
    		     
              var aInfoResult= result1.split('@@@') ;
              var nNumOff = aInfoResult.length;
             
              var j;
              
              //aggiorno le colonne per tutte le righe
              for ( j=0; j <= nNumOff -1 ; j++ ){
                
                //alert(aInfoResult[j]);
                SetStatoFirmeAvvalimneti( aInfoResult[j] );
      
              }  
              
           }
          }
        }
    }   
    
  
  }

}


//aggiorna per una singola riga le colonne StatoFirme e presenzaAvvalimenti
function SetStatoFirmeAvvalimneti(paramStatoFirme){
  
  var TitleModifica = CNV('../../' , 'Allegati Offerta' );
  
 
  
  var aInfoUpgrade = paramStatoFirme.split(";");
  var lIdMsgUpdate = aInfoUpgrade[0];
  var StatoFirmeUpgrade = aInfoUpgrade[1];
  var PreAvvalimentiUpgrade = aInfoUpgrade[2];
  
  //recupero numero righe griglia valutazione
  var nRow = getObj('NumProduct_Valutazione_griglia').value;
  
  //recupero posizione colonna StatoFirme
  var colStatoFirme = GetColumnPositionInGrid('StatoFirme','Valutazione_griglia');
  
  //recupero posizione colonna StatoFirme
  var colPresAvvalimenti = GetColumnPositionInGrid('PresenzaAvvalimenti','Valutazione_griglia');
  
  var lIdMsgCurr ;
  var objCellCurr ;
  var objhiddenCurr ;
  
  
  var k;
  for ( k=1; k <= nRow; k++ ){
      
      //recupero idmsg della riga
      lIdMsgCurr = -1 ;
      lIdMsgCurr = getObj('Valutazione_griglia_' + k + '_0').value;
      
      if ( lIdMsgCurr == lIdMsgUpdate){
        
        //aggiorno colonna Avvalimenti
        objCellCurr = null;
        objCellCurr = getObj('cell_Valutazione_griglia_' + k + '_' + colPresAvvalimenti);
        
        objhiddenCurr = null;
        objhiddenCurr = getObj('Valutazione_griglia_' + k + '_' + colPresAvvalimenti);
       
        if ( PreAvvalimentiUpgrade == '0'){
          objCellCurr.innerHTML = 'No';
          objhiddenCurr.value= '0#~No';
        }else{
          objCellCurr.innerHTML = 'Si';
          objhiddenCurr.value= '1#~Si';     
        }
        
        //aggiorno colonna StatoFirme
        objCellCurr = null;
        objCellCurr = getObj('cell_Valutazione_griglia_' + k + '_' + colStatoFirme);
        
        objhiddenCurr = null;
        objhiddenCurr = getObj('Valutazione_griglia_' + k + '_' + colStatoFirme);
        
        PathImgCurr='';
        if ( StatoFirmeUpgrade == 'uguale'){
          TitleModifica = CNV('../../' , 'stesso firmatario' );
          PathImgCurr='<img border=0 src="../../CTL_LIBRARY/images/domain/uguale.png">';
          objCellCurr.innerHTML = '<a title="' + TitleModifica + '" href="#" onclick="javascript:ALLEGATI_OFFERTA('+ lIdMsgCurr + ');">' +  PathImgCurr + '</a>';
          objhiddenCurr.value= 'uguale#~uguale';
        }
        
        if ( StatoFirmeUpgrade == 'diverso'){
          TitleModifica = CNV('../../' , 'firmatario diverso' );
          PathImgCurr='<img border=0 src="../../CTL_LIBRARY/images/domain/diverso.png">';
          objCellCurr.innerHTML = '<a title="' + TitleModifica + '" href="#" onclick="javascript:ALLEGATI_OFFERTA('+ lIdMsgCurr + ');">' +  PathImgCurr + '</a>';
          objhiddenCurr.value= 'diverso#~diverso';     
        }
        
        if ( StatoFirmeUpgrade == 'nessuno'){
          TitleModifica = CNV('../../' , 'nessun firmatario' );
          PathImgCurr='<img border=0 src="../../CTL_LIBRARY/images/domain/nessuno.png">';
          objCellCurr.innerHTML = '<a title="' + TitleModifica + '" href="#" onclick="javascript:ALLEGATI_OFFERTA('+ lIdMsgCurr + ');">' +  PathImgCurr + '</a>';
          objhiddenCurr.value= 'nessuno#~nessuno';
        }
        
        if ( StatoFirmeUpgrade == 'incorso'){
          TitleModifica = CNV('../../' , 'Elaborazione in corso...' );
          PathImgCurr='<img border=0 src="../../CTL_LIBRARY/images/domain/incorso.png">';
          objCellCurr.innerHTML = '<a title="' + TitleModifica + '" href="#" onclick="javascript:ALLEGATI_OFFERTA('+ lIdMsgCurr + ');">' +  PathImgCurr + '</a>';
          objhiddenCurr.value= 'incorso#~incorso';
        }
        
        break;
        
  	 }
      
  }
  
}


//disabilita comandi se bando revocato
function DisableComandiBandoRevocato(){
  
  ajax = GetXMLHttpRequest(); 
  
	if(ajax){
				 
		  ajax.open("GET", '../../ctl_library/functions/Check_BandoRevocato.asp?DOCUMENT=DOCUMENTO_GENERICO&IDDOC=' + getObj('IdDoc_Bando').value , false);
	 		 
			ajax.send(null);
			
			if(ajax.readyState == 4) {
			
				if(ajax.status == 200)
				{
				
				  if ( ajax.responseText != '' ) {
				    var strresult = ajax.responseText;
				    //alert(strresult);              
				    
				    if ( strresult == '1' ){
              
              alert(CNV('../../' , 'Bando Revocato' ));
                
              //NASCONDO CALCOLO ECONOMICO
              try{
                getObj( 'IMG_Valutazione_griglia_Valutazione/Punteggio Economico5' ).style.display='none';
                getObj( 'Valutazione_griglia_Valutazione/Punteggio Economico5' ).style.display='none';
              } catch(e){  
              }
                
              //NASCONDO CALCOLO OFFERTE ANOMALE
              try{
                getObj( 'IMG_Valutazione_griglia_Valutazione/Calcola offerte anomale9' ).style.display='none';
                getObj( 'Valutazione_griglia_Valutazione/Calcola offerte anomale9' ).style.display='none';
              } catch(e){  
              }
              
              //NASCONDO SORTEGGIO
              try{
                getObj( 'IMG_Valutazione_griglia_Valutazione/Sorteggio7' ).style.display='none';
                getObj( 'Valutazione_griglia_Valutazione/Sorteggio7' ).style.display='none';
              } catch(e){  
              }
            }  
            
				    
				  }
				}
			}

	}
  
}

//nasconde Comandi Aggiudicataria Invitati se non Invito
function HideComandiAggiudicataria(){
  if ( getObj('TipoBando').value != '3' ){
    
    //nascondio esito provvisorio invitati
    try{
      getObj( 'SPN_PRINT_DOCUMENT_8' ).style.display='none'; 
      try { getObj( 'LNK_PRINT_DOCUMENT_8' ).style.display='none'; }catch(e){}
      
    } catch(e){  
      
      //try { getObj( 'LNK_OPEN_CREATE_12' ).style.display='inline'; }catch(e){}
      //try { getObj( 'IMG_OPEN_CREATE_12' ).style.display='inline'; }catch(e){}
      
    };
    
    //nascondio esito definitivo invitati
    try{
      getObj( 'SPN_PRINT_DOCUMENT_10' ).style.display='none'; 
      try { getObj( 'LNK_PRINT_DOCUMENT_10' ).style.display='none'; }catch(e){}
      
    } catch(e){  
      
      //try { getObj( 'LNK_OPEN_CREATE_12' ).style.display='inline'; }catch(e){}
      //try { getObj( 'IMG_OPEN_CREATE_12' ).style.display='inline'; }catch(e){}
      
    };
    
  
  }
}
      
//esegue azioni dopo evento open sul documento
function Action_AFTER_OPEN( param ){
  
  if ( param != 'Cover1' )
    GetStatoFirmeAvvalimenti();
  
}
  
</script>

