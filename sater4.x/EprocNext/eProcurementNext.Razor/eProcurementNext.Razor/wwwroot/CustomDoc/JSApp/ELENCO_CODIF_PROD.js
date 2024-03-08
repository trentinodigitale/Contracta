function cercaperambito(tipoProd)
{
	var ambito = getObjValue('MacroAreaMerc');
	
	tipoProd = tipoProd || 'meta'; //Default per il parametro opzionale tipoProd
	
	if ( ambito == '' )
	{
		DMessageBox( '../' , 'E\' necessario selezionare prima un ambito' , 'Attenzione' , 1 , 400 , 300 );
		return false;
	}
	else
	{
		var oldAction = document.forms[0].action;
		
		var oldDocument = getQSParamNew(oldAction, 'document');
		var oldMod = getQSParamNew(oldAction, 'modgriglia');

		var newDocument = '';
		var newMod = '';
		
		if ( tipoProd == 'meta' )
		{
			newMod = 'ELENCO_CODIFICHE_META_PRODOTTI_' + ambito + '_MOD_Griglia';
			newDocument = 'DOCUMENT_CODIFICA_PRODOTTO_' + ambito;
		}
		else
		{
			newMod = 'ELENCO_CODIFICHE_PRODOTTI_' + ambito + '_MOD_Griglia';
			newDocument = 'DOCUMENT_CODIFICA_PROD_' + ambito;
		}

		var newAction = ReplaceExtended(oldAction,'document=' + oldDocument, 'document=' + newDocument);
		newAction = ReplaceExtended(newAction,'modgriglia=' + oldMod,'modgriglia=' + newMod);

		document.forms[0].action = newAction;
	}
	
	
}



function VerificaDominiCodifica( param )
{
	
	
	var idrow = getObj('GridViewer_idRow_' + GridViewer_StartRow  ).value;
	var process_param = '';
	//alert(idrow);
	if ( param == 'META' )
		
		process_param = 'VERIFICA,CODIFICHE_META_PRODOTTI&CAPTION=Verifica Valori Domini Codifiche&TABLE=document_microlotti_dettagli&KEY=id&FIELD=';
	else
		
		process_param = 'VERIFICA,CODIFICHE_PRODOTTI&CAPTION=Verifica Valori Domini Codifiche&TABLE=document_microlotti_dettagli&KEY=id&FIELD=';
		
	parent.Viewer_Command.location =  'ViewerCommand.asp?IDLISTA=' + idrow + '&PROCESS_PARAM=' + process_param ;

}


function CaricaMacroProdotti ( param )
{	
	var ambito = getObjValue('MacroAreaMerc');
	if ( ambito == '' )
	{
		DMessageBox( '../' , 'E\' necessario selezionare prima un ambito' , 'Attenzione' , 1 , 400 , 300 );
		return false;
	}
	else
	{
		MakeDocFrom('CARICA_MACROPRODOTTI##AMBITO#'+ ambito  );
	}	
}


function MyViewerExcel ( param )
{
	
	var objForm;
	var altro;
	var vet;	
	//debugger;

	vet = param.split( '#' );

	var w;
	var h;
	var Left;
	var Top;
    
    if( vet.length < 2  )
    {
		w = screen.availWidth;
		h = screen.availHeight;
		Left=0;
		Top=0;
	}
	else    
	{
		var d;
		d = vet[1].split( ',' );
		w = d[0];
		h = d[1];
		Left = (screen.availWidth-w)/2;
		Top  = (screen.availHeight-h)/2;
		
		if( vet.length > 2 )
		{
			altro = vet[2];
		}
	}

	//-- recupero i Query string per passarla alla stampa
	var QS = getObj('QueryString').value.toUpperCase();
	//-- tolgo il vecchhio parametro table
	QS = QS.replace('=DASHBOARD_VIEW_ELENCO_CODIFICHE_META_PRODOTTI','=DASHBOARD_VIEW_ELENCO_CODIFICHE_META_PRODOTTI_EXCEL');
	QS = QS.replace('=DASHBOARD_VIEW_ELENCO_CODIFICHE_PRODOTTI','=DASHBOARD_VIEW_ELENCO_CODIFICHE_PRODOTTI_EXCEL');
	
	var win;
	win = ExecFunction( 'viewerExcel_x.asp?OPERATION=EXCEL' +  '&'  + QS + '&' + vet[0]  , '' , '' );
	
}




