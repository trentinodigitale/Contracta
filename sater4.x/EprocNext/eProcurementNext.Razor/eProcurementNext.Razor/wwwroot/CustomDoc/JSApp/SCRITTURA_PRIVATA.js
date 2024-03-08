window.onload = FIRMA_OnLoad;

//usata dal viewer per aprire la comunicazione
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
   
	var Stato ='';
	
	if ( getObj('StatoDoc') )
	{
		
		Stato = getObjValue('StatoDoc');
		
		if (( getObjValue('F1_SIGN_LOCK') =='0' || getObjValue('F1_SIGN_LOCK') =='' ) && Stato=='Saved' )
		{
			document.getElementById('generapdf').disabled = false; 
			document.getElementById('generapdf').className ="generapdf";
		}
		else
		{
			document.getElementById('generapdf').disabled = true; 
			document.getElementById('generapdf').className ="generapdfdisabled";
		}

		if (Stato == 'Saved' && ( getObjValue('F1_SIGN_LOCK') != '0' &&  getObjValue('F1_SIGN_LOCK') != '' ) ) 
		{
			document.getElementById('attachpdf').disabled = false; 
			document.getElementById('attachpdf').className ="generapdf";
		}
		else
		{
			document.getElementById('attachpdf').disabled = true; 
			document.getElementById('attachpdf').className ="generapdfdisabled";
		}

		if ( ( getObjValue('F1_SIGN_LOCK') != '0' &&  getObjValue('F1_SIGN_LOCK') != '' ) && (Stato == 'Saved') )
		{
			document.getElementById('editistanza').disabled = false; 
			document.getElementById('editistanza').className ="attachpdf";
		}
		else
		{
			document.getElementById('editistanza').disabled = true; 
			document.getElementById('editistanza').className ="attachpdfdisabled";
		}

		//Nascondo le colonne aggiunte nel modello base del contratto, utili per il giro CONTRATTO_GARA
		/*
		try
		{
			ShowCol( 'BENI' , 'EsitoRiga' , 'none' );
		}
		catch(e){}
		*/
		try
		{
			ShowCol( 'BENI' , 'Voce' , 'none' );
		}
		catch(e){}
		
		try
		{
			ShowCol( 'BENI' , 'FNZ_DEL' , 'none' );
		}
		catch(e){}


	}
	
	//tolgo la lente dove non ci sono documenti
	hide_lente_operazioni_effettuate();
		
}

function GeneraPDF()
{
	var bPassCheck = true
	
	if ( getObjValue('firmatario') == '' )
	{
		TxtErr('firmatario');
		bPassCheck=false;
	}

	
	if ( getObjValue('CF_FORNITORE') == '' )
	{
		TxtErr('CF_FORNITORE');
		bPassCheck=false;
	}
	
	
	
	if ( getObjValue('firmatario_OE') == '' )
	{
		TxtErr('firmatario_OE');
		bPassCheck=false;
	}
	
	
	if ( ! bPassCheck )
		DMessageBox( '../' , 'Per proseguire e\' necessaria la compilazione di tutti i campi evidenziati' , 'Attenzione' , 1 , 400 , 300 );
	else
		PrintPdfSign('URL=/report/prn_SCRITTURA_PRIVATA.ASP?SIGN=YES&PDF_NAME=SCRITTURA_PRIVATA&TABLE_SIGN=CTL_DOC_SIGN&IDENTITY_SIGN=IdHeader&AREA_SIGN=F1');

}

function TogliFirma () 
{
	DMessageBox( '../' , 'Si sta per eliminare il file firmato.' , 'Attenzione' , 1 , 400 , 300 );	
	ExecDocProcess( 'SIGN_ERASE_CTL_DOC_SIGN,FirmaDigitale');  
}

function CheckCoerenza( objfield )
{
	
	if ( getObj('DataScadenza').value != '' && getObj('DataStipula').value != '' )
	{
		if (CheckData('DataScadenza', getObjValue('DataStipula'), 'Compilare Data Scadebza', 'Data Scadenza deve essere maggiore di Data Stipula Contratto') == -1) 
		{
			objfield.value='';
			return -1;
		}
	}
	
}

function CheckData(FieldData, Riferimento, msgVuoto, msgMinoreRif) {
    if (getObjValue(FieldData) == '') 
	{              
        try {getObj(FieldData + '_V').focus();} catch (e) {};
        DMessageBox('../', msgVuoto, 'Attenzione', 1, 400, 300);
        return -1;
    }

    if (getObjValue(FieldData) <= Riferimento) 
	{   
        try { getObj(FieldData + '_V').focus();} catch (e) {};
        DMessageBox('../', msgMinoreRif, 'Attenzione', 1, 400, 300);
        return -1;
    }

    return 0;
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