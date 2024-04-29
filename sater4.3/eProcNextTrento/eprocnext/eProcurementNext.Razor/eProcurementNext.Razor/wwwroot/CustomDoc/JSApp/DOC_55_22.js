
<script language="javascript">

var ProceduraNegoziata = '15478' ;
var ATI_Mandataria = '1' ;
var ATI_Mandante = '2' ;

var Stato_New     = '0';
var Stato_Saved   = '1';
var Stato_Sended  = '2';

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


//RIMAPPO LA FUNZIONE DI SEND PER FARE DEI CONTROLLI CUSTOM
var oldSend=PRINT;

function NewSend(){
  
  //non faccio il controllo in caso di gara in economia o negoziata
  if ( getObj('ProceduraGara').value != ProceduraNegoziata && getObj('ProceduraGara').value != ProceduraEconomia ){
	
  	if ( getObj('NumProduct_DOCUMENTAZIONE_griglia').value < 1 ){
		 
		  alert('La busta di documentazione deve contenere almeno una riga');
		  DrawLabel('1'); 
		  FUNC_DOCUMENTAZIONE();
		  return;
		  
		}
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
  
  //CONTROLLI SEND BASE
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
  
  //CONTROLLI CANSEND  
  if ( ExecEvent("SEND") != 0 )
    return ;
  
  //CHIEDO CONFERMA SE IL FORNITORE STA PARTECIPANDO  ALLA GARA ANCHE IN UN RAGGRUPPAMENTO RTI
  var nCheckRTI=0;
  nCheckRTI = CheckFornitoreInRTI();

  if ( nCheckRTI == 1 ){
    if (  confirm( CNV ('../../' , 'Stai Partecipando alla Gara in Forma Indiretta. Vuoi continuare' ) ) == false ) 
      return ;
  } 
  
  oldSend('');
}

PRINT = NewSend ;	


window.onload = InitOfferta ;

function InitOfferta() {
  
  //nascondo area allegati della sezione tecnica e della sezione economica in caso di nuovo documento
  try{
  strdata=getObj('ReceivedDataMsg').value;
  
  if ( strdata > '2009-10-30T00:00:00')
  	nHide=1;
  
  if (getObj('Stato').value == '0' || getObj('Stato').value == '1' || nHide==1){
  	setVisibility(getObj('DIV_DOCUMENTAZIONE_allegati'),'none');
  }
  }catch(e){
  }

  
  //gestione aree RTI,CONSORZIO,AVVALIMENTO se non richieste
  HandleAreeRTI();
  
  
  //se si tratta di una ProceduraGara=MarketPlace/In Economica e TipoBando=Avviso
  //nascondiamo la busta di documentazione
  if  ( ( getObj('ProceduraGara').value == ProceduraNegoziata || getObj('ProceduraGara').value == ProceduraEconomia ) && getObj('TipoBando').value == Avviso )  {
			
	hObjSection = getObj( 'DOCUMENTAZIONE_Hide' );                   
    hObjSection.value = 1 ;     
	DrawLabel( LinkAttivo ); 
	
  }else{
  
  	DrawLabel('1'); 
  	FUNC_DOCUMENTAZIONE();
	
  }
  
  
  //EVIDENZIO SE IL FORNITORE PARTECIPA ALLA GARA IN UN RAGGRUPPAMENTO
  if ( getObj('Stato').value == Stato_New || getObj('Stato').value == Stato_Saved ){
    
    //Se non sono nel contesto INWORK del documento
  	if ( getQSParamFromString(window.location.toString(),'Provenienza') != 'INWORK'){	
      
  		var nCheckRTI=0;
  		nCheckRTI = CheckFornitoreInRTI();
  		
  		if ( nCheckRTI == 1 )
  		  alert( CNVAJAX ('../../' , 'Stai Partecipando alla Gara in Forma Indiretta' ) );
  	}	
  }
  
}




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
      
      //controllo che è settata la mandataria
      if ( nIsMandataria == 0 ) {
        alert( CNVAJAX ('../../' , 'inserire la Mandataria ATI' ) );
        //ExecFunction( '../../ctl_library/MessageBoxWin.asp?ML=yes&MSG=inserire la Mandataria ATI&CAPTION=Attenzione&ICO=2' , 'MSGBOX' , strPosition );
        DrawLabel('1'); 
        FUNC_DOCUMENTAZIONE();
        return false;  
      
      }     
      
      
      //controllo che è settata la mandante
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
  
  //controllo se partecipacomeRTI è settato che la griglia RTi è compilata correttamente
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
  
  //se ho settato Consorzio a si controllo che la griglia consorzio è compilata correttamente
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
  
  //se ho settatto RicorriAvvalimento controllo che la griglia avvalimento è compilata correttamente
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
    	      INSERTARTICLE('4863','1','55','22','','DOCUMENTAZIONE_ATIgriglia','Inserisci mandante','1');
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
        
        //svuoto il campo del CF che non è univoco
        //this.value='';
        
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
  
  //controlla che questo codice fiscale non sia già presente
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
    
    //controllo se partecipacomeRTI è settato
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
    
    
    
    //controllo se InserisciEsecutriciLavori è settato
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
        
        //se non è settata RTI aggiungo all'inizio la ragsoc del consorzio
    		if ( strvalueRTI != '1'	){
    			nPosDesc=GetColumnPositionInGrid('RagSocConsorzio',strFullNameArea);
    			objDenominazioneATI.value = getObj(strFullNameArea + '_1_' + nPosDesc ).value + ' ' + objDenominazioneATI.value ;
    		}
            
      }
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

