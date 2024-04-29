window.onload = FIRMA_OnLoad;

function MyOpenDocumentColumn(objGrid , Row , c)
{
	var cod;
	var nq;
	
	try	{ 	cod = getObj( 'R' + Row + '_GridViewer_ID_DOC').value;	}catch( e ) {};
	
	if ( cod == '' || cod == undefined )
	{
		try	{ 	cod = getObj( 'R' + Row + '_GridViewer_ID_DOC')[0].value; }catch( e ) {};
	}
	var strDoc = '';
	
	try	{ 	strDoc = getObj( 'R' + Row + '_GridViewer_OPEN_DOC_NAME').value;	}catch( e ) {};
	
	if ( strDoc == '' || strDoc == undefined )
	{
		try	{ 	strDoc = getObj( 'R' + Row + '_GridViewer_OPEN_DOC_NAME')[0].value; }catch( e ) {};
	}
	ShowDocument( strDoc , cod );
}

function FIRMA_OnLoad()
{
   
	//js presente anche dietro al viewer Gestione Convenzioni | Aggiudicazioni in attesa di Convenzioni
	//USATA PER IL KPF 507042, in quanto con il parametro filter nel codice VB fa una lcase del valore passato e non funzione per il valore AggiudicazioneDef presente sul dominio	
	try {			
			var valore = document.getElementById('FormViewerFiltro').StatoRiga.value;
			
			if ( valore == '' )
				valore='AggiudicazioneDef';
			
			SetDomValue( 'StatoRiga' , valore );	
			
		}catch(e){};
		
	var StatoFunzionale ='';

	/*if ( getObj('StatoDoc') )
	{

		StatoFunzionale = getObjValue('StatoFunzionale');

		if (( getObjValue('F1_SIGN_LOCK') =='0' || getObjValue('F1_SIGN_LOCK') =='' ) && StatoFunzionale=='InLavorazione' )
		{
			document.getElementById('generapdf').disabled = false; 
			document.getElementById('generapdf').className ="generapdf";
		}
		else
		{
			document.getElementById('generapdf').disabled = true; 
			document.getElementById('generapdf').className ="generapdfdisabled";
		}

		if (StatoFunzionale == 'InLavorazione' && ( getObjValue('F1_SIGN_LOCK') != '0' &&  getObjValue('F1_SIGN_LOCK') != '' ) ) 
		{
			document.getElementById('attachpdf').disabled = false; 
			document.getElementById('attachpdf').className ="generapdf";
		}
		else
		{
			document.getElementById('attachpdf').disabled = true; 
			document.getElementById('attachpdf').className ="generapdfdisabled";
		}

		if ( ( getObjValue('F1_SIGN_LOCK') != '0' &&  getObjValue('F1_SIGN_LOCK') != '' ) && (StatoFunzionale == 'InLavorazione') )
		{
			document.getElementById('editistanza').disabled = false; 
			document.getElementById('editistanza').className ="attachpdf";
		}
		else
		{
			document.getElementById('editistanza').disabled = true; 
			document.getElementById('editistanza').className ="attachpdfdisabled";
		}
		
	}
		*/
	//PER I CONTRATTI DI INIZIATIVA NASCONDO IL CHECK Presenza listino

	try
	{
		if ( getObjValue('CONTRATTO_INIZIATIVA') == '1' )
		{
			$("#cap_PresenzaListino").parents("table:first").css({"display": "none"});
			$("#cap_DataRiferimentoInizio").parents("table:first").css({"display": "none"});
			$("#cap_ProtocolloRiferimento").parents("table:first").css({"display": "none"});
			$("#cap_DataScadenzaOfferta").parents("table:first").css({"display": "none"});
			$("#cap_Fascicolo").parents("table:first").css({"display": "none"});

		}
		
	}catch(e){}
	
	
	
	onChangePresenzaListino();
	HideCestinodoc();
	
	//tolgo la lente dove non ci sono documenti
	hide_lente_operazioni_effettuate();
	
	

}

function onChangePresenzaListino()
{
	var DOCUMENT_READONLY = getObjValue('DOCUMENT_READONLY');
	
	var checkPresenzaListino;
	
	if ( DOCUMENT_READONLY == '1' )
	{
		checkPresenzaListino = getObjValue('PresenzaListino');
	}
	else
	{
		if ( getObj( 'PresenzaListino' ).checked )
			checkPresenzaListino = '1';
		else
			checkPresenzaListino = '0';	
	}
	
		
		
	//Se il check 'presenza listino' è spuntato mostro sia la sezione prodotti che la sezione firma. altrimenti le nascondo
	if ( checkPresenzaListino == '0' || checkPresenzaListino == '' )
	{
		getObj('TESTATA_PRODOTTI').style.display = 'none';
		getObj('BENI').style.display = 'none';
		getObj('FIRMA').style.display = 'none';
	}
	else
	{
		getObj('TESTATA_PRODOTTI').style.display = '';
		getObj('BENI').style.display = '';
		getObj('FIRMA').style.display = '';
	}
	
}

function GeneraPDF()
{
	ExecDocProcess( 'CHECK_AND_PDF,CONTRATTO_GARA');
}

function afterProcess( param )
{
	if ( param == 'CHECK_AND_PDF' )
    {
		PrintPdfSign('URL=/report/prn_CONTRATTO_GARA.ASP?SIGN=YES&PDF_NAME=CONTRATTO_GARA&TABLE_SIGN=CTL_DOC_SIGN&IDENTITY_SIGN=IdHeader&AREA_SIGN=F1');
	}
	
	
	if ( param == 'SAVE_DOC' )
	{
		ElabAIC();  
	}
	
	//ho cliccato sul comando Stipula Contratto
	if (param == 'FITTIZIO3' || param =='ANNULLA_STIPULA_CONTRATTO' ) 
	{
		
		//verifica se esiste un verbale di stipula contratto in lavorazione
		var idDocStipulaContratto= getObjValue('idDocStipulaContratto');
		
		//alert(idDocStipulaContratto);
		if ( idDocStipulaContratto != '' )
		{
			var Title = 'Attenzione';
			var ML_text = 'Esiste un documento in lavorazione. Premi Ok per annullarlo e crearne uno nuovo altrimenti cancel';
			var ICO = 3;
			var page = 'ctl_library/MessageBoxWin.asp?MODALE=YES&ML=YES&MSG=' + encodeURIComponent( ML_text ) +'&CAPTION=' + encodeURIComponent(Title) + '&ICO=' + encodeURIComponent(ICO);
			ExecFunctionModaleConfirm( page, null , 200 , 400 , '', 'Annulla_StipulaContratto' , 'StipulaContrattoBase' );
			
		}
		else
		{
			StipulaContrattoBase();
		}
	}
	
}

function TogliFirma () 
{
	DMessageBox( '../' , 'Si sta per eliminare il file firmato' , 'Attenzione' , 1 , 400 , 300 );	
	ExecDocProcess( 'SIGN_ERASE_CTL_DOC_SIGN,FirmaDigitale');  
}

function AddProdotto( )
{
  
	var strCommand = 'BENI#ADDFROM#IDROW=' + getObjValue( 'IDDOC' ) + '&TABLEFROMADD=DOCUMENT_ADD_PRODOTTO' 
	ExecDocCommand( strCommand );
}

function DownLoadCSV() 
{
	var TipoBando = getObjValue('ModelloBando');
	var codModello;
	
	if ( getObj('Modello') )
	{
		codModello = getObjValue('Modello');
	}
	else
	{
		codModello = 'MODELLI_LOTTI_' + TipoBando + '_MOD_SCRITTURA_PRIVATA';
	}
	
	
	ExecFunction('../../CTL_Library/accessBarrier.asp?goto=xlsx.aspx&TitoloFile=contratto&FILTER=&TIPODOC=CONTRATTO_GARA&MODEL=' + codModello + '&VIEW=&HIDECOL=ESITORIGA&Sort=&SHOW_ATTACH=NO&IDDOC=' + getObjValue('IDDOC'), '_blank', '');

}

function OnClickProdotti(obj)
{
    var DOCUMENT_READONLY = getObjValue('DOCUMENT_READONLY');
	//var TipoBando = getObjValue('ModelloBando');

    if (DOCUMENT_READONLY == "1")
        DMessageBox('../', 'Documento in sola lettura', 'Attenzione', 1, 400, 300);
    else
        ImportExcel('CAPTION_ROW=yes&TITLE=Upload Excel&TABLE=CTL_Import&FIELD=RTESTATA_PRODOTTI_MODEL_Allegato&SHEET=0&PARAM=posizionale&PROCESS=LOAD_PRODOTTI,CONTRATTO_GARA&OWNER_FIELD=Idpfu&OPERATION=INSERT#new#600,450');
}
function BENI_AFTER_COMMAND ()
{
	HideCestinodoc();
	//TEST su sentinella inserita sul documento, non salvata per non mostrarlo più volte
	if ( getObjValue('colonnatecnica') != '1' )
	{
		DMessageBox('../', 'Si suggerisce di verificare il valore del contratto prima dell\'invio dello stesso', 'Attenzione', 1, 400, 300);
		getObj('colonnatecnica').value = '1';
	}
	
}


function HideCestinodoc()
{
	
	var DOCUMENT_READONLY = getObjValue('DOCUMENT_READONLY');
	
	if (DOCUMENT_READONLY != "1")
	{
		try{
			var i = 0;
			
			
			if ((getObj('StatoDoc').value == 'Saved' || getObj('StatoDoc').value == '' ) )
			{
				for( i=0; i < DOCUMENTAZIONEGrid_EndRow+1 ; i++ )
				{
					if( getObj( 'RDOCUMENTAZIONEGrid_' + i + '_Obbligatorio' ) . value == '1' )
					{
						
						getObj( 'DOCUMENTAZIONEGrid_r' + i + '_c0' ).innerHTML = '&nbsp;';
					}
				}
			}
	   }catch(e){}
   }
}


function DOCUMENTAZIONE_AFTER_COMMAND ()
{
	HideCestinodoc();
}


function MyOpenViewerAziende(){

  
  //aggiorno documento in meoria
  UpdateDocInMem( getObj( 'IDDOC' ).value, getObj( 'TYPEDOC' ).value );

  //apro il viewer per selezionare azienda
  OpenViewer('Viewer.asp?OWNER=&Table=dashboard_view_aziende&ModelloFiltro=&ModGriglia=&Filter=&IDENTITY=IDAZI&lo=base&HIDE_COL=&DOCUMENT=CONTRATTO_GARA&PATHTOOLBAR=../CustomDoc/&JSCRIPT=CONTRATTO_GARA&AreaAdd=no&Caption=Seleziona Amministrazione Aggiudicatrice&Height=180,100*,210&numRowForPag=20&Sort=aziragionesociale&SortOrder=asc&Exit=si&AreaFiltro=&AreaFiltroWin=1&TOOLBAR=dashboard_view_aziende_toolbar&ACTIVESEL=1&FilterHide=Aziacquirente<>0&ONSUBMIT=&doc_to_upd='+ getObj('IDDOC').value );

}

function ChangeMittenteSelRow  ( objGrid , Row , c ){
  
  
  var idRow;
  var DOC_TO_UPD=getQSParam('doc_to_upd');
	
		
	idRow = getObj('GridViewer_idRow_' + Row ).value;
	
  	
	var nocache = new Date().getTime();
	var param;
		
	param='IDDOC=' + DOC_TO_UPD + '&TYPEDOC=CONTRATTO_GARA&SECTION=DOCUMENT&FIELD=Azienda&FIELD_VALUE=' + idRow ;
	
	ajax = GetXMLHttpRequest();		
	
	ajax.open("GET",'../ctl_library/document/Upd_Field_Document_InMem.asp?' + param + '&nocache=' + nocache , false);
	ajax.send(null);
	//alert(ajax.readyState);
	if(ajax.readyState == 4) 
	{
	  //alert(ajax.status); 
		if(ajax.status == 404 || ajax.status == 500)
		{
		  alert('Errore invocazione pagina');				  
		}
	  //alert(ajax.responseText); 
		if ( ajax.responseText == 'OK' ) 
		{
			//ritorno al documento di codifica prodotti se tutto ok
			breadCrumbPop('');
		}
		
		if ( ajax.responseText == 'ERRORE_DOCUMENTO_DA_AGGIORNARE' ) 
		{
		 alert('Errore: Stato del documento da aggiornare diverso da in lavorazione');				  
		}
	 
	 }
		 

  
}



function MyOpenViewerAggiudicatario(){

  
  //aggiorno documento in meoria
  UpdateDocInMem( getObj( 'IDDOC' ).value, getObj( 'TYPEDOC' ).value );

  //apro il viewer per selezionare azienda
  OpenViewer('Viewer.asp?OWNER=&Table=DASHBOARD_VIEW_FORNITORI&ModelloFiltro=&ModGriglia=dashboard_view_AggiudicatarioGriglia&Filter=&IDENTITY=IDAZI&lo=base&HIDE_COL=&DOCUMENT=CONTRATTO_GARA&PATHTOOLBAR=../CustomDoc/&JSCRIPT=CONTRATTO_GARA&AreaAdd=no&Caption=Seleziona Aggiudicatario&Height=180,100*,210&numRowForPag=20&Sort=aziragionesociale&SortOrder=asc&Exit=si&AreaFiltro=&AreaFiltroWin=1&TOOLBAR=dashboard_view_aziende_toolbar&ACTIVESEL=1&FilterHide=AziVenditore > 0&ONSUBMIT=&doc_to_upd='+ getObj('IDDOC').value );

}

function ChangeAggiudicatarioSelRow  ( objGrid , Row , c ){
  
  
  var idRow;
  var DOC_TO_UPD=getQSParam('doc_to_upd');
	
		
	idRow = getObj('GridViewer_idRow_' + Row ).value;
	
  	
	var nocache = new Date().getTime();
	var param;
		
	param='IDDOC=' + DOC_TO_UPD + '&TYPEDOC=CONTRATTO_GARA&SECTION=DOCUMENT&FIELD=Destinatario_Azi&FIELD_VALUE=' + idRow ;
	
	ajax = GetXMLHttpRequest();		
	
	ajax.open("GET",'../ctl_library/document/Upd_Field_Document_InMem.asp?' + param + '&nocache=' + nocache , false);
	ajax.send(null);
	//alert(ajax.readyState);
	if(ajax.readyState == 4) 
	{
	  //alert(ajax.status); 
		if(ajax.status == 404 || ajax.status == 500)
		{
		  alert('Errore invocazione pagina');				  
		}
	  //alert(ajax.responseText); 
		if ( ajax.responseText == 'OK' ) 
		{
			//ritorno al documento di codifica prodotti se tutto ok
			breadCrumbPop('');
		}
		
		if ( ajax.responseText == 'ERRORE_DOCUMENTO_DA_AGGIORNARE' ) 
		{
		 alert('Errore: Stato del documento da aggiornare diverso da in lavorazione');				  
		}
	 
	 }
		 

  
}
function CheckCoerenza( objfield )
{

	ck_VD( objfield );
	
	if ( getObj('DataScadenza').value != '' && getObj('DataStipula').value != '' )
	{
		if (CheckData('DataScadenza', getObjValue('DataStipula'), 'Compilare Data Scadebza', 'Data Scadenza deve essere maggiore di Data Stipula Contratto') == -1) 
		{
			objfield.value='';
			return -1;
		}
	}
	
	//per salvare i cambiamneti fatti a data stipula
	ExecDocProcess('FITTIZIO4,DOCUMENT,,NO_MSG');
	
}

function CheckData(FieldData, Riferimento, msgVuoto, msgMinoreRif) {
    if (getObjValue(FieldData) == '') 
	{              
        try {getObj(FieldData + '_V').focus();} catch (e) {};
        DMessageBox('../', msgVuoto, 'Attenzione', 1, 400, 300);
        return -1;
    }
	
	//alert(getObjValue(FieldData));
	//alert(Riferimento);
	
    if (getObjValue(FieldData) <= Riferimento) 
	{   
        try { getObj(FieldData + '_V').focus();} catch (e) {};
		
        DMessageBox('../', msgMinoreRif, 'Attenzione', 1, 400, 300);
        return -1;
    }

    return 0;
}



function GetDatiAIC()
{
	ExecDocProcess('SAVE_DOC,AIC,,NO_MSG');
}


function ElabAIC()
{
	// IdOfferta
	var IDDOC = getObjValue('IDDOC');
	
	
	
	if ( isSingleWin() )
	{
		var url;
		
		url = encodeURIComponent( 'CustomDoc/AIC_LOAD.asp?IDDOC=' + IDDOC + '&TYPEDOC=CONTRATTO_GARA&lo=base' );
		NewWin = ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?url=' + url + '&KEY=document'   ,  '' , '');
		
	}
	else
	{
		ExecFunctionCenter('../../CustomDoc/AIC_LOAD.asp?IDDOC=' + IDDOC + '&TYPEDOC=CONTRATTO_GARA' );
	}  
	
	
	
	//alert(IDDOC);
}




//CRONOLOGIAGrid_FNZ_OPEN_extraAttrib
function hide_lente_operazioni_effettuate()
{
	var cod;
	numrow = GetProperty( getObj('CRONOLOGIAGrid') , 'numrow');
	pos = GetPositionCol( 'CRONOLOGIAGrid' , 'FNZ_OPEN' , '' );

	for( i = 0 ; i <= numrow ; i++ )
	{
		
		cod = getObj( 'R' + i + '_CRONOLOGIAGrid_ID_DOC').value;
		
		if ( cod > 0 )
		{
			cod=cod;
		}
		else
		{			
			getObj( 'CRONOLOGIAGrid_r' + i + '_c' + pos ).innerHTML = '&nbsp;';			
			setClassName(getObj(  'CRONOLOGIAGrid_r' + i + '_c' + pos  ),'');
			
		}
	}	


}

function StipulaContratto(param)
{
	//se ci sono state modifiche innesca un processo fittizio per il salva
	if ( FLAG_CHANGE_DOCUMENT == 1)
		ExecDocProcess('FITTIZIO3,DOCUMENT,,NO_MSG');
	else
		ExecFunctionCenter (param);
}



function StipulaContrattoBase(param)
{
	var strUrl = '../../customdoc/Crea_Verbale_PDA.asp?TIPODOC=CONTRATTO_GARA&CONTESTO=CONTRATTO_GARA&INNESCO=CONTRATTO_GARA&IDDOC=' + getObj('IDDOC').value + '##600,400'
	ExecFunctionCenter (strUrl);
}

function Annulla_StipulaContratto(param)
{
	//var strUrl = '../../customdoc/Crea_Verbale_PDA.asp?TIPODOC=CONTRATTO_GARA&CONTESTO=CONTRATTO_GARA&INNESCO=CONTRATTO_GARA&IDDOC=' + getObj('IDDOC').value + '##600,400'
	//ExecFunctionCenter (strUrl);
	ExecDocProcess('ANNULLA_STIPULA_CONTRATTO,CONTRATTO_GARA,,NO_MSG');
}
