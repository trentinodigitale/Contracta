
function ViewerDelConfirm( grid , indRiga , indCol )
{
	var cod;
	var CurFilter;
	var CurPage;
	var CurSort;
	var CurSortOrder;
	var CurTable;
	var CurQueryString;
	
	//debugger;
	if ( confirm(getObj( 'MsgConfirmDel').value ) )
	{
	
		//-- recupero il codice della riga passata
		cod = GetIdRow( 'GridViewer' , indRiga , 'self' );
	
	
		//-- recupero il filtro utilizzato
		CurFilter = getObjPage( 'CurFilter', 'self' ).value;
	
	
		//-- il numero della pagina 
		CurPage = getObjPage( 'CurPage', 'self' ).value;

		//-- il sort corrente
		CurSort = getObjPage( 'CurSort', 'self' ).value;

		//-- il sort corrente
		CurSortOrder = getObjPage( 'CurSortOrder', 'self' ).value;


		//-- la tabella corrente
		CurTable = getObjPage( 'CurTable', 'self' ).value;
	
		//-- altri parametri di configurazione
		CurQueryString = getObjPage( 'QueryString', 'self' ).value;

		var URL = 'ViewerGriglia.ASP?' +  'MODE=DEL&IDROW=' + escape(cod) + '&' + CurQueryString;
	
		//ExecFunction( 'ViewerGriglia.ASP?' +  'MODE=DEL&IDROW=' + escape(cod)+ '&Filter=' + CurFilter + '&nPag=' + CurPage + '&Sort=' + CurSort + '&SortOrder=' + CurSortOrder + '&Table=' + CurTable + CurQueryString, 'ViewerGriglia' , '' );
		ExecFunction( URL , 'ViewerGriglia' , '' );
	}
}

