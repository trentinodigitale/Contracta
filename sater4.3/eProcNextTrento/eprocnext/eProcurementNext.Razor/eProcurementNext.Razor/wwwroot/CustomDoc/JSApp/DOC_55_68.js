
<script language="javascript">
//Versione=1&data=2012-05-11&Attvita=38055&Nominativo=Francesco

var w_err=350;
var h_err=150;
var Left_err = (screen.availWidth-w_err)/2;
var Top_err  = (screen.availHeight-h_err)/2;
var strPosition = ',left=' + Left_err + ',top=' + Top_err + ',width=' + w_err + ',height=' + h_err ;

var oldSend;

function NewSend()
{


  var strDataApertura=getObj('DataAperturaOfferte').value;
	//Controllo che il campo data di apertura offerte sulla testata sia maggiore o uguale del campo “presentare le offerte entro il”
	if ( ( getObj('ExpiryDate').value >  getObj('DataAperturaOfferte').value ) || strDataApertura.length < 10 )
	{
		alert('La data \'data di apertura offerte\' deve essere maggiore o uguale della data \'Rispondere entro il\'');
		DrawLabel('0'); 
		FUNC_Cover1();
		getObj('DataAperturaOfferte_vis').focus();
		return;
	}

		//innesco i controlli base di tipo CANSEND del documento
		if  ( ! SENDBASE())
		return;

	//se devo inserire i destinatari lo controllo dando un messaggio 
  //if ( nNumCurrCompany_CompanyDes == 0 ){
    
  //  alert(CNV ('../../' , 'Inserire almeno un Destinatario' ));
  //  DrawLabel('1'); 
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
  				
  				
  				if (campoN.value == '' || parseFloat(campoN.value) <= 0 ){
            alert(CNV ('../../' , 'Valorizzare gli importi nella busta economica' ));
  		      DrawLabel('2'); 
  		      FUNC_ECONOMICA();
  		      return;
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
  	
  	
  	if ( parseFloat(getObj('ImportoBaseAsta2').value) != parseFloat(totPrz) )
  	{
  		alert('L\'importo base asta in testata non coincide con il totale degli \'importo base asta\' presenti sulla busta economica');
  		DrawLabel('2'); 
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
    DrawLabel('2'); 
    FUNC_ECONOMICA();
    return;
  }
	
	oldSend('SEND,APPROVAZIONE');
	
}	

//SEND = NewSend;	



//INVOCO SETTAGGI APPENA E' PRONTO IL DOC DELLA PAGINA
window.onload = Init_RichiestaPreventivo;
function Init_RichiestaPreventivo()
{
	//controllo se rimappare la SEND in funzione del ciclo di approvazione	
	if (getObj('AdvancedState').value!='4' && getObj('Stato').value!='2' )
	{
	
	  oldSend=ExecDocProcess;
		ExecDocProcess = NewSend;
	}

	
	
	CustomActionOnGrid('ECONOMICA_griglia');
	
	
	//nasocndo valore offerta e valore offerta in lettere a prescindere
	var iddztValoreOfferta = get_IdDztFromDztNome_AreaOfid('ECONOMICA_comune','ValoreOfferta');
	var iddztValoreOffertaLettere = get_IdDztFromDztNome_AreaOfid('ECONOMICA_comune','TotaleInLettere');
	setVisibility(getObj('lbl_elemento_ECONOMICA_comune_' + iddztValoreOfferta),'none');
	setVisibility(getObj('Vis_elemento_ECONOMICA_comune_' + iddztValoreOfferta),'none');
  setVisibility(getObj('lbl_elemento_ECONOMICA_comune_' + iddztValoreOffertaLettere),'none');
  setVisibility(getObj('elemento_ECONOMICA_comune_' + iddztValoreOffertaLettere),'none');
	
	
	//gestione sezione destinatari
  HandleSezioneDestinatari();
	
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

