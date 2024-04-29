window.onload = FIRMA_OnLoad;

function FIRMA_OnLoad()
{
   
	var StatoFunzionale ='';

	if ( getObj('StatoDoc') )
	{

		StatoFunzionale = getObjValue('StatoFunzionale');
		IdpfuInCharge = getObjValue('IdpfuInCharge');
		
		if ( idpfuUtenteCollegato == undefined )
			tmp_idpfuUtenteCollegato = getObjValue('IdpfuInCharge');
		else
			tmp_idpfuUtenteCollegato = 	idpfuUtenteCollegato;

		if (( getObjValue('F1_SIGN_LOCK') =='0' || getObjValue('F1_SIGN_LOCK') =='' ) && StatoFunzionale=='Inviato' && IdpfuInCharge == tmp_idpfuUtenteCollegato )
		{
			document.getElementById('generapdf').disabled = false; 
			document.getElementById('generapdf').className ="generapdf";
		}
		else
		{
			document.getElementById('generapdf').disabled = true; 
			document.getElementById('generapdf').className ="generapdfdisabled";
		}

		if (StatoFunzionale == 'Inviato' && ( getObjValue('F1_SIGN_LOCK') != '0' &&  getObjValue('F1_SIGN_LOCK') != '' ) && IdpfuInCharge == tmp_idpfuUtenteCollegato ) 
		{
			document.getElementById('attachpdf').disabled = false; 
			document.getElementById('attachpdf').className ="generapdf";
		}
		else
		{
			document.getElementById('attachpdf').disabled = true; 
			document.getElementById('attachpdf').className ="generapdfdisabled";
		}

		if ( ( getObjValue('F1_SIGN_LOCK') != '0' &&  getObjValue('F1_SIGN_LOCK') != '' ) && (StatoFunzionale == 'Inviato') && IdpfuInCharge == tmp_idpfuUtenteCollegato )
		{
			document.getElementById('editistanza').disabled = false; 
			document.getElementById('editistanza').className ="attachpdf";
		}
		else
		{
			document.getElementById('editistanza').disabled = true; 
			document.getElementById('editistanza').className ="attachpdfdisabled";
		}
		
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

	}
	
	//tolgo la lente dove non ci sono documenti
	hide_lente_operazioni_effettuate();
	
}

function AllegaFileFirmato()
{
	var idDoc;
	idDoc = getObjValue('IDDOC');
	
	ExecFunctionCenterDoc('../functions/field/uploadattachsigned.asp?TABLE=CTL_DOC_SIGN&IDDOC=' + idDoc + '&OPERATION=INSERTSIGN&IDENTITY=IdHeader&AREA=F2&DOMAIN=FileExtention&FORMAT=#AllegaFirma#600,400');
    
}

function onChangePresenzaListino()
{
	var DOCUMENT_READONLY = getObjValue('DOCUMENT_READONLY');
	
	var checkPresenzaListino;
	
	checkPresenzaListino = getObjValue('PresenzaListino');
	
		
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

function DownLoadCSV() 
{
	var TipoBando = getObjValue('ModelloBando');
	var codModello;
	
	if ( getObj('Modello') && getObjValue('Modello') != '' )
	{
		codModello = getObjValue('Modello');
	}
	else
	{
		codModello = 'MODELLI_LOTTI_' + TipoBando + '_MOD_SCRITTURA_PRIVATA';
	}
	
	
	ExecFunction('../../CTL_Library/accessBarrier.asp?goto=xlsx.aspx&TitoloFile=contratto&FILTER=&TIPODOC=CONTRATTO_GARA_FORN&MODEL=' + codModello + '&VIEW=&HIDECOL=EsitoRiga&Sort=&IDDOC=' + getObjValue('IDDOC'), '_blank', '');
}

function OnClickProdotti(obj)
{
    var DOCUMENT_READONLY = getObjValue('DOCUMENT_READONLY');
	var F1_SIGN_HASH = getObjValue('F1_SIGN_HASH');
	//var TipoBando = getObjValue('ModelloBando');

    if (DOCUMENT_READONLY == "1" || F1_SIGN_HASH != '')
        DMessageBox('../', 'Documento in sola lettura', 'Attenzione', 1, 400, 300);
    else
        ImportExcel('CAPTION_ROW=yes&TITLE=Upload Excel&TABLE=CTL_Import&FIELD=RTESTATA_PRODOTTI_MODEL_Allegato&SHEET=0&PARAM=posizionale&PROCESS=LOAD_PRODOTTI,CONTRATTO_GARA&OWNER_FIELD=Idpfu&OPERATION=INSERT#new#600,450');
}

function GeneraPDF()
{
	ExecDocProcess( 'CHECK_AND_PDF,CONTRATTO_GARA');
}

function afterProcess( param )
{
	if ( param == 'CHECK_AND_PDF' )
    {
		PrintPdfSign('URL=/report/prn_CONTRATTO_GARA.ASP?SIGN=YES&PDF_NAME=LISTINO_CONTRATTO&TABLE_SIGN=CTL_DOC_SIGN&IDENTITY_SIGN=IdHeader&AREA_SIGN=F1');
	}
	
	if ( param == 'SAVE_DOC' )
	{
		ElabAIC();  
	}
}

function TogliFirma () 
{
	DMessageBox( '../' , 'Si sta per eliminare il file firmato' , 'Attenzione' , 1 , 400 , 300 );	
	ExecDocProcess( 'SIGN_ERASE_CTL_DOC_SIGN,CONTRATTO_GARA');  
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
		
		url = encodeURIComponent( 'CustomDoc/AIC_LOAD.asp?IDDOC=' + IDDOC + '&TYPEDOC=CONTRATTO_GARA_FORN&lo=base' );
		NewWin = ExecFunctionSelf(pathRoot + 'ctl_library/path.asp?url=' + url + '&KEY=document'   ,  '' , '');
		
	}
	else
	{
		ExecFunctionCenter('../../CustomDoc/AIC_LOAD.asp?IDDOC=' + IDDOC + '&TYPEDOC=CONTRATTO_GARA_FORN' );
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