window.onload = FIRMA_OnLoad;

function FIRMA_OnLoad()
{
   
	var Stato ='';
	Stato = getObjValue('StatoFunzionale');



	if ( Stato=='Inviato' && getObjValue('IdpfuInCharge') != '0' )
	{
		document.getElementById('attachpdfpatto').disabled = false; 
		document.getElementById('attachpdfpatto').className ="attachpdf";
	}
	else
	{
		document.getElementById('attachpdfpatto').disabled = true; 
		document.getElementById('attachpdfpatto').className ="attachpdfdisabled";
	}
	
	//Nascondo le colonne aggiunte nel modello base del contratto, utili per il giro CONTRATTO_GARA
	try
	{
		ShowCol( 'BENI' , 'EsitoRiga' , 'none' );
	}
	catch(e){}

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
	
	//tolgo la lente dove non ci sono documenti
	hide_lente_operazioni_effettuate();
	
}

function AllegaFileFirmato()
{
	var idDoc;
	idDoc = getObjValue('IDDOC');
	
	ExecFunctionCenterDoc('../functions/field/uploadattachsigned.asp?TABLE=CTL_DOC_SIGN&IDDOC=' + idDoc + '&OPERATION=INSERTSIGN&IDENTITY=IdHeader&AREA=F2&DOMAIN=FileExtention&FORMAT=#AllegaFirma#600,400');
    
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