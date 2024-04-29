
<script language="javascript">
//Versione=1&data=2012-10-17&Attvita=39758&Nominativo=Francesco

var PDA_CriterioPrezzobasso	= '15531';
var PDA_OffertaVantaggiosa	= '15532';

var PDA_CriterioFormulazioneOffertePrezzo		 = '15536';
var PDA_CriterioFormulazioneOffertePercentuale = '15537';

var PDA_OffAnomaleAutomatica	= '16309';
var PDA_OffAnomaleValutazione	= '16310';

var FirmaBusta_SI_MICROLOTTI = '4;MicroLotti';
var FirmaBusta_SI_CAUZIONE = '4;DOCUMENTAZIONE,MicroLotti';

var w_err=350;
var h_err=150;
var Left_err = (screen.availWidth-w_err)/2;
var Top_err  = (screen.availHeight-h_err)/2;
var strPosition = ',left=' + Left_err + ',top=' + Top_err + ',width=' + w_err + ',height=' + h_err ;

var oldSend;

function NewSend()
{
	
	//innesco i controlli base di tipo CANSEND del documento
  if  ( ! SENDBASE())
	 return;
	
  var strDataApertura=getObj('DataAperturaOfferte').value;
	//Controllo che il campo data di apertura offerte sulla testata sia maggiore o uguale del campo “presentare le offerte entro il”
	//alert('scadenza=' + getObj('ExpiryDate').value);
	//alert('apertura=' + getObj('DataAperturaOfferte').value);
	if ( ( getObj('ExpiryDate').value >  getObj('DataAperturaOfferte').value ) || strDataApertura.length < 10 )
	{
		alert('La data \'data di apertura offerte\' deve essere maggiore o uguale della data di scadenza dell\'offerta');
		DrawLabel('0'); 
    FUNC_Cover1();
    getObj('DataAperturaOfferte_vis').focus();
		return;
	}
	
	//se devo inserire i destinatari lo controllo dando un messaggio 
  //if ( nNumCurrCompany_CompanyDes == 0 ){
    
  //  alert(CNV ('../../' , 'Inserire almeno un Destinatario' ));
  //  DrawLabel('3'); 
  //  FUNC_CompanyDes();
  //  return;
  //}  
	
	
	var nomeCompletoGriglia = 'ECONOMICA_griglia';
	var colPos = GetColumnPositionInGrid('PrzBaseAsta',nomeCompletoGriglia);
	var colQTOrd =GetColumnPositionInGrid('CARQuantitaDaOrdinare',nomeCompletoGriglia);
  
	if ( colPos != -1){
    
    //SE NELLA BUSTA ECOBOMICA PRESENTE attributo PrzBaseAsta controllo che 
    //La somma degli importi base asta sulla sezione 'busta economica' deve essere uguale
	  //a importo base asta presente in testata
    
  	var nIndRrow;
  	var objRow=getObj('NumProduct_'+ nomeCompletoGriglia); 
  	var nNumRow=Number(objRow.value);
  	var totPrz = 0.0;
  	var objvalueQT;
  	var objvalueQTVis;
  	if (nNumRow > 0)
  	{
  		for (nIndRrow=1;nIndRrow<=nNumRow;nIndRrow++)
  		{
  			try
  			{
  				
  				var campoN = getObj(nomeCompletoGriglia + '_' + nIndRrow + '_' + colPos);
  				
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
  	
  	
  	if ( parseFloat(getObj('ImportoBaseAsta2').value) != parseFloat(totPrz) )
  	{
  		alert('L\'importo base asta in testata non coincide con il totale degli \'importo base asta\' presenti sulla busta economica');
  		DrawLabel('6'); 
  		FUNC_ECONOMICA();
  		return;
  	}
	
	}
	
	//verifico che se presenti gli attributi CarQuantitaDaOrdinare,Peso,Coefficiente
  //siano maggiori di 0
  var strAttribCheck = '';
  strAttribCheck = CheckAttributiBustaEconomica();
  
  if ( strAttribCheck != '' ){
    alert( CNV('../../' , strAttribCheck + ' deve essere maggiore di 0' ) );
    DrawLabel('6'); 
    FUNC_ECONOMICA();
    return;
  }
	
	var iddztValutazione = get_IdDztFromDztNome_AreaOfid('CRITERI_comune','Punteggioeconomico');
	
	var objEcono = getObj('Vis_elemento_CRITERI_comune_' + iddztValutazione);
	
	if (objEcono.value == '' || parseFloat(objEcono.value) <= 0)
	{
		alert('La valutazione economica deve essere maggiore di 0');
		DrawLabel('2'); 
    FUNC_CRITERI();
		objEcono.focus();
		return;
	}
	
	
	//controllo che la formula economica sia valorizzata
	var iddztFormulaValutazione = get_IdDztFromDztNome_AreaOfid('CRITERI_comune','EconomicExpression');
	var objFormulaEcono = getObj('elemento_CRITERI_comune_' + iddztFormulaValutazione);
	var objbuttonFormula = getObj('btn_elemento_CRITERI_comune_' + iddztFormulaValutazione);
	
	if ( objFormulaEcono.value == '' )
	{
		alert(CNV ('../../' , 'La Formula Economica deve essere valorizzata' ));
		DrawLabel('2'); 
    FUNC_CRITERI();
    objbuttonFormula.focus();
		return;
	}
	
	
	//criterio di aggiudicazione = AL PREZZO + BASSO  e criterio di formulazione offerta= importo 
	//allora importo a base d'asta è obbligatorio
	var CriterioAggiudicazioneGara = getObj('CriterioAggiudicazioneGara').value;
	//alert (CriterioAggiudicazioneGara);
	var CriterioFormulazioneOfferte = getObj('CriterioFormulazioneOfferte').value;
	
  /*
  if ( CriterioAggiudicazioneGara == PDA_CriterioPrezzobasso && CriterioFormulazioneOfferte == PDA_CriterioFormulazioneOffertePrezzo ) {
		
		var importobaseasta=getObj('ImportoBaseAsta2').value;
		if ( importobaseasta == '' || importobaseasta == '0'){
			
			alert('Il campo Importo Base Asta e\' obbligatorio.');
			DrawLabel('1'); 
			FUNC_Cover1();
			getObj('Vis_ImportoBaseAsta2').focus();
			return;
			
		}
	}
	*/
	
	//se criterio=OFFERTA ECONOMICAMENTE + VANTAGGIOSA verificare che l'attributo
	//OffAnomale=valutazione
	try{
		var OffAnomale = getObj('OffAnomale').value;
		
		if ( CriterioAggiudicazioneGara == PDA_OffertaVantaggiosa && getObj('CalcoloAnomalia').value != '0' && OffAnomale != PDA_OffAnomaleValutazione ) {
		//if ( CriterioAggiudicazioneGara == PDA_OffertaVantaggiosa && OffAnomale != PDA_OffAnomaleValutazione ) {
			
			alert('Il campo Offerte anomale deve essere settato a Valutazione.');
			getObj('OffAnomale').focus();
			return;       		  
			
		}
		
	}catch(e){}
	
	
	
	//se critrio offerta + vantaggiosa controllo che la somma dei MAX punteggi economico e tecnico sia=100
	if ( CriterioAggiudicazioneGara == PDA_OffertaVantaggiosa ){
		
		//recupero iddzt di PunteggioEconomico
		//var ListAttrib = getObj('ListAttrib_CRITERI_comune').value;
		//var ainfo = ListAttrib.split('#');
		//for ( i=0; i < ainfo.length; i++ ){
		//						
		//						var InfoAttrib=ainfo[i];
		//						
		//						ainfo1=ainfo[i].split(';');
		//						
		//						if (ainfo1[0] == 'Punteggioeconomico'){
		//							
		//							var MAXPuntECO = parseFloat ( getObj('elemento_CRITERI_comune_' + ainfo1[1] ).value ) ; 
		//							
		//					  }
		//  }  		
		
		
		
   	var MAXPuntECO = parseFloat ( getObj('elemento_CRITERI_comune_' + get_IdDztFromDztNome_AreaOfid('CRITERI_comune','Punteggioeconomico') ).value ) ; 
		
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
			DrawLabel('2'); 
      FUNC_CRITERI();
      return;
		}
		
	}
	//CONTROLLO CHE LA BUSTA ECONODMICA ABBIA ALMENO UNA RIGA NELLA SEZ ATTI GARA
	try{
    if ( getObj('NumProduct_ECONOMICA_attidigara').value < 1 ) {
  		
  		//alert('La busta di documentazione deve contenere almeno un allegato');
  		//ExecFunction( '../../ctl_library/MessageBoxWin.asp?ML=yes&MSG=La busta economica deve avere almeno una riga per la griglia relativa agli atti di gara&CAPTION=Attenzione&ICO=2' , 'MSGBOX' , strPosition );
  		alert(CNV ('../../' , 'La busta economica deve avere almeno una riga per la griglia relativa agli atti di gara' ));
  		DrawLabel('6'); 
  		FUNC_ECONOMICA();
  		
  		return;
  		
  	}
	}catch(e){}
	
	// ---------------------------------------------------------------
	// ---------------------------------------------------------------
	// ---------------------------------------------------------------
	// ---------------------------------------------------------------
	// ---------------------------------------------------------------
	// ---------------------------------------------------------------
	// ---------------------------------------------------------------
	// ---------------------------------------------------------------
	// ---------------------------------------------------------------
	// ---------------------------------------------------------------
	// ---------------------------------------------------------------
	
	//	fare il controllo di congruenza tra l'leneco degli importoBase sulla griglia con ImportoBaseAsta2 sulla testata
	//	alert('errore in italiano');
	//	return;
	
	oldSend('SEND,APPROVAZIONE');
	
	
}	

//SEND = NewSend;	

//conservo la lista completa delle opzioni
var ObjCriterioDiValutazioneCompleta;
var Old_CriterioAggiudicazioneGara_onchange;
var Old_CriterioFormulazioneOfferte_onchange;
var Old_CalcoloAnomalia_onchange;
var selValueCriterioValutazione ;



//INVOCO SETTAGGI APPENA E' PRONTO IL DOC DELLA PAGINA
window.onload = SetOnChangeAttributi;


function SetCriterioValutazione(){
	
	try{
		Old_CriterioAggiudicazioneGara_onchange();
		Old_CriterioFormulazioneOfferte_onchange();
		}catch(e){
		
	}
	
	/*
	//commentato in quanto CriterioDiValutazione non presente sul cottimo 48
	//se CriterioAggiudicazioneGara=Offerta Economicamnete + vantagg. in CriterioValutazione ci sarà la voce "Con Coefficienti"
	if ( getObj('CriterioAggiudicazioneGara').value != PDA_OffertaVantaggiosa ){
	rimuovivoce ( 'coefficienti' );
	getObj('lblCoefficienteX').style.display='none';
	getObj('CoefficienteX').style.display='none';
	getObj('lblCriterioDiValutazione').style.display='none';
	getObj('CriterioDiValutazione').style.display='none';
	SetFormula();
	}else{
	 aggiungivoce ( 'coefficienti' );
	 getObj('lblCoefficienteX').style.display='inline';
   getObj('CoefficienteX').style.display='inline';
   getObj('lblCriterioDiValutazione').style.display='inline';
   getObj('CriterioDiValutazione').style.display='inline';
	}
	
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
	*/
	
	if ( getObj('CriterioAggiudicazioneGara').value == PDA_CriterioPrezzobasso) 
	  {
		//svuoto la griglia
         ResetGridRTI ( 'CRITERI_griglia' , '' );	
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
      
	
}


function SetOnChangeAttributi()
{
	
	
	
	//controllo se rimappare la SEND in funzione del ciclo di approvazione	
	if (getObj('AdvancedState').value!='4' && getObj('Stato').value!='2' )
	{
	
	    oldSend=ExecDocProcess;
		  ExecDocProcess = NewSend;
		  
	}
	try
	{ 
		if ( getObj('Stato').value == '0' || ( getObj('Stato').value == '1' && getObj('AdvancedState').value != '4' && getObj('AdvancedState').value != '5' ) ){
			
			Rimuovivoce_Esteso ( 'RequestsignTemp' , FirmaBusta_SI_MICROLOTTI );
			Rimuovivoce_Esteso ( 'RequestsignTemp' , FirmaBusta_SI_CAUZIONE );
			
			//commentato in quanto CriterioDiValutazione non presente sul cottimo 48
          	//selValueCriterioValutazione = getObj('CriterioDiValutazione').value ;
			
			//CopiaListaCompleta();
			
			//svuota();
			
			//aggiungivoce ( 'altro' );
			
			
			Old_CriterioAggiudicazioneGara_onchange = getObj('CriterioAggiudicazioneGara').onchange;      
			getObj('CriterioAggiudicazioneGara').onchange = SetCriterioValutazione ;
			
			Old_CriterioFormulazioneOfferte_onchange = getObj('CriterioFormulazioneOfferte').onchange;
			getObj('CriterioFormulazioneOfferte').onchange = SetCriterioValutazione ;
			
			
			SetCriterioValutazione();
			
			
			try{
			 //associo azione onchange per preimpostare la formula se CriterioDiValutazione  <> altro
			 getObj('CriterioDiValutazione').onchange = SetFormula ;
			}catch(e){}
			
			try{
			 //associo azione onchange per preimpostare il coefficiente giusto se la formula è allegatop
			 getObj('CoefficienteX').onchange = SetFormula ;
			 
			}catch(e){}
			
			
		}
		//comportamento non editabile
		else
		{
		 //nascondo grligliacriteri se criterioaggiudicazionegara al prezzo più basso e non editabile
		 if ( getObj('CriterioAggiudicazioneGara').value == PDA_CriterioPrezzobasso) 
		  {
			 //setStyleProp(getObj('CRITERI_griglia'),'visibility','hidden');
			 setVisibility(getObj('CRITERI_griglia'),'none');
		  }	
		}
		
	}
	catch(e) {}
	
	//Nascondiamo colonna
	
	try {
    CustomActionOnGrid('ECONOMICA_griglia'); //al caricamento nascondiamo colonna PrzUnOfferta e Sconto
	}catch(e) {}
	
	try {
	 CustomActionOnGrid('CRITERI_griglia'); //al caricamento	 nascondiamo colonna TechnicalExpression
	}catch(e) {}
	
	iddztValoreOfferta = get_IdDztFromDztNome_AreaOfid('ECONOMICA_comune','ValoreOfferta');
	iddztValoreOffertaLettere = get_IdDztFromDztNome_AreaOfid('ECONOMICA_comune','TotaleInLettere');
	
	//Nascondiamo il campo valoreOfferta
	try {
	 setStyleProp(getObj('lbl_elemento_ECONOMICA_comune_' + iddztValoreOfferta),'visibility','hidden');
	}catch(e) {}
	
	try {
    setStyleProp(getObj('Vis_elemento_ECONOMICA_comune_' + iddztValoreOfferta),'visibility','hidden');
  }catch(e) {}
  
  try {
	 setStyleProp(getObj('lbl_elemento_ECONOMICA_comune_' + iddztValoreOffertaLettere),'visibility','hidden');
	}catch(e) {}
	
  try {
	 setStyleProp(getObj('elemento_ECONOMICA_comune_' + iddztValoreOffertaLettere),'visibility','hidden');
	}catch(e) {}
	
	//a prescindere nasconde nella sezione dei criteri il campo Formula Valutazione Tecnica
	try {
    HideFormulaValutazioneTecnica();
	}catch(e) {}
	
	try {
  	//nascondo il campo OffAnomale se il Calcolo Anomalia non è richiesto 
  	Old_CalcoloAnomalia_onchange = getObj('CalcoloAnomalia').onchange ;
  	getObj('CalcoloAnomalia').onchange = onChangeAnomalia ;
  	onChangeAnomalia();
	}catch(e) {}
	
		
	//nasconde il campo allegato nella busta economica
	HideAllegatoBustaEconomica();
	
	//gestione sezione destinatari
  HandleSezioneDestinatari();
	
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



function Rimuovivoce_Esteso( ListName , value_selezionato ){
	
	num_option=getObj( ListName ).options.length;
	
  for(a=0;a<num_option;a++){
		if(getObj( ListName ).options[a].value == value_selezionato){
			getObj( ListName ).options[a]=null;
			break;
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
	//var ListAttrib = getObj('ListAttrib_CRITERI_comune').value;
	//var ainfo = ListAttrib.split('#');
	//var ainfo1 ;
	//var InfoAttrib ;
	var iddztEconomicExpression;
	var iddztValoreOfferta;
	var iddztPunteggioEconomico;
	 
	iddztEconomicExpression = get_IdDztFromDztNome_AreaOfid('CRITERI_comune','EconomicExpression');
	iddztPunteggioEconomico = get_IdDztFromDztNome_AreaOfid('CRITERI_comune','Punteggioeconomico');
	
	getObj('Vis_elemento_CRITERI_comune_' + iddztPunteggioEconomico ).value = '' ;
  getObj('elemento_CRITERI_comune_' + iddztPunteggioEconomico ).value = '' ;
  
   //se CriterioAggiudicazioneGara = prezzo + basso setto la formula punteggio*ValoreOfferta e Putenggio=1
  if ( getObj('CriterioAggiudicazioneGara').value == PDA_CriterioPrezzobasso ){
   
    result = 'Punteggio*Valore Offerta';
    getObj('elemento_CRITERI_comune_' + iddztEconomicExpression ).value = result ;
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
		getObj('btn_elemento_CRITERI_comune_' + iddztEconomicExpression ).style.display='none';
		
		}else {
		
		getObj('elemento_CRITERI_comune_' + iddztEconomicExpression ).value = '' ;
		getObj('label_elemento_CRITERI_comune_' + iddztEconomicExpression ).innerHTML = '' ;
		getObj('btn_elemento_CRITERI_comune_' + iddztEconomicExpression ).style.display='';
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


function CustomActionOnGrid(nomeCompletoGriglia)
{
	var nIndRrow;
	var objRow=getObj('NumProduct_'+ nomeCompletoGriglia); 
	
	var nNumRow=Number(objRow.value);
	
	if (nNumRow > 0)
	{
		for (nIndRrow=1;nIndRrow<=nNumRow;nIndRrow++)
		{
			try
			{
				var colPos = GetColumnPositionInGrid('PrzUnOfferta',nomeCompletoGriglia);
				var campoN = getObj('Vis_' + nomeCompletoGriglia + '_' + nIndRrow + '_' + colPos);
				
				if (document.all != null) //Explorer
				campoN.style.setAttribute('visibility','hidden');
				else
				campoN.setAttribute('style','visibility: hidden');
				
			}
			catch(e){}
			
			try
			{
				colPos = GetColumnPositionInGrid('Sconto',nomeCompletoGriglia);
				var campoN = getObj('Vis_' + nomeCompletoGriglia + '_' + nIndRrow + '_' + colPos);
				if (document.all != null) //Explorer
				campoN.style.setAttribute('visibility','hidden');
				else
				campoN.setAttribute('style','visibility: hidden');
			}
			catch(e){}
			
			try
			{
				//btn_CRITERI_griglia_1_6
				colPos = GetColumnPositionInGrid('TechnicalExpression',nomeCompletoGriglia);
				var campoN = getObj('btn_' + nomeCompletoGriglia + '_' + nIndRrow + '_' + colPos);
				if (document.all != null) //Explorer
				campoN.style.setAttribute('visibility','hidden');
				else
				campoN.setAttribute('style','visibility: hidden');
			}
			catch(e){}
			
		}
	}
	
	 //OPERAZIONI SULLA GRIGLIA BUSTA DOCUMENTAZIONE
     if ( nomeCompletoGriglia == 'DOCUMENTAZIONE_griglia'){
        
        //nascondo colonna Allegato
        HideAllegatoBustaEconomica();
     }
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





//nasconde nella sezione dei criteri il campo Formula Valutazione Tecnica
function HideFormulaValutazioneTecnica()
{
	var idDzt_valTec;
	idDzt_valTec= get_IdDztFromDztNome_AreaOfid('CRITERI_comune','ExpForTechnicalScore');
	
	
	var criterio = getObj('CriterioAggiudicazioneGara').value;
	var table = getObj('TableContainer_CRITERI_comune');
	
	//Facciamo sparire sempre il campo Formula Valutazione Tecnica
	//label che contiene il valore del campo
	try{
		setStyleProp(getObj('label_elemento_CRITERI_comune_' + idDzt_valTec),'visibility','hidden');
		getObj('label_elemento_CRITERI_comune_' + idDzt_valTec).innerHTML = '';
	}catch(e){}
	
	//label che contiene la descrizione del campo
	setStyleProp(getObj('lbl_elemento_CRITERI_comune_' + idDzt_valTec),'visibility','hidden');
	getObj('elemento_CRITERI_comune_' + idDzt_valTec).value = '';
	
	//bottone per selezionare la formula
	try{
		setStyleProp(getObj('btn_elemento_CRITERI_comune_' + idDzt_valTec),'visibility','hidden');
	}catch(e){}
	
}

function setStyleProp(campo,prop,value)
{
	if (document.all != null) //Explorer
    campo.style.setAttribute(prop,value);
	else
    campo.setAttribute('style',prop + ':' + value);
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

  
//Gestione Sezione Destinatari:
//se doc salvato visualizzo nuovo viewer altrimenti vecchia griglia
function HandleSezioneDestinatari(){
  
  
  //se ho la nuova area dei destinatari
  if ( getObj('iframe_CompanyDes_ViewerDestinatari') != null ){
     
    //se documento nuovo/salvato visualizzo nuovo viewer altrimenti vecchio
    if ( getObj('Stato').value == '0' ||  getObj('Stato').value == '1' ){
      
      //nascondo il comando esporta in excel
      try{getObj('CompanyDes_GridDest_Esporta in Excel1').style.display='none'; }catch(e){}
      
      //nascondo la vecchia area
      getObj( 'CompanyDes_GridDest' ).style.display='none'; 
      
      //carico nella nuov aarea il nuovo viewer 
      var IdHeader = getObj('lIdMsgPar').value;
      
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
  
  

function RefreshContent(){
  
   if ( getObj('Stato').value == '2' )
  {
	self.location=self.location;
  }
  
  
  //se ho la nuova area dei destinatari
  if ( getObj('iframe_CompanyDes_ViewerDestinatari') != null ){
  
    if ( getObj('Stato').value != '2' ){
    
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

</script>

