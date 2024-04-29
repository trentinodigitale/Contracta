
function BudGet_AddUpd_ChangeValuta(  )
{
	//-- recupera la valuta per l'azienda selezionata e la inserisce nella combo delle valute
	var objValuta;
	try {
	
		//debugger;
		
		var objPlant = getObj( 'BDD_KeyPlant' );
		
		//-- nel caso non ci sia una plant selezionata svuoto il campo valuta
		if ( objPlant.value == '' ) 
		{
			objValuta = getObj( 'BDD_Valute' );
			objValuta.selectIndex = -1;
		}
		else
		{
			//-- altrimenti seleziono la valuta associata alla societ
			var soc = objPlant.value;//.split('#')[0];
			
			//-- cerco la societ
			var i;
			
			for( i = 0; i < numSocieta ; i++ )
			{
				if ( Plant[i] == soc )
				{
					var objSoc = getObj( 'BDD_KeySOC' );
					objSoc.value = Societa[i];
					
					objValuta = getObj( 'BDD_Valute' );
					//objValuta.selectIndex = i;
					objValuta.value = Valute[i];
					return;
				
				}
			
			}
		}
		
		alert( 'Attenzione azienda non presente' );
	
		
	}
	catch( e ) {
		objValuta = getObj( 'BDD_Valute' );
		objValuta.selectIndex = -1;
	};

	try {

		FldExtDomResetValue( 'BDD_KEYCDC' );

	}
	catch( e ) {
	};
	

}

function OnChangeProgetto( obj )
{
	var objCDC = getObj( 'BDD_KEYCDC_edit' );

	var objPlant = getObj( 'BDD_KeyPlant_edit' );

	if( objPlant.value.substring( 0,2 ) != objCDC.value.substring( 0,2 ) && objCDC.value != '' )
	{
		alert( 'La selezione non e\' corretta');
		FldExtDomResetValue( 'BDD_KEYCDC' );
	}

}


function BloccaImpegno()
{

	var Ret = "0" ;
	var tmpVirtualDir;
	tmpVirtualDir = '/Application';

	if ( isSingleWin() )
		tmpVirtualDir = urlPortale;
	
	ajax = GetXMLHttpRequest(); 
	if(ajax)
	{
		 
			ajax.open("GET", tmpVirtualDir + '/Budget/BudgetCheckPermessoImpegno.asp?' , false);
			ajax.send(null);
			if(ajax.readyState == 4) {
				if(ajax.status == 200)
				{
					Ret = ajax.responseText;
				}
			}

	} 
	
	if (Ret=='0')
	{
		getObj('BDD_KeyProgetto').disabled=true;
		getObj('BDD_Note').disabled=true;
	}
}

window.onload = BloccaImpegno ;



