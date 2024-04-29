
function budget_CambiValute_Griglia_OnUpd( strNameGrid,nIndRow,nIndCol )
{
	var nIdDett;
	var query;
	var val;
	
	//debugger;
	//alert( 'inizio' );
	nIdDett=GetIdRow( strNameGrid , nIndRow , '')
	//alert( 'nIdDett = ' + nIdDett);
	try {
		query = getObj( 'QUERYSTRING' );
		//alert( 'query = ' + query);
		
		try {
			val = getObj( 'R'+ nIndRow + '_BDV_ValueDest' )[0].value;
		}catch( e ) 
		{
			val = getObj( 'R'+ nIndRow + '_BDV_ValueDest' ).value;
		}
		//alert( 'val = ' + val);
		
		/*
		var winGrid = opener.getObj( 'Budget_Griglia' );
		winGrid.document.location = winGrid.document.location;
		alert( winGrid.document.location );
		*/
		
		

		//ExecFunction( 'Budget_Griglia.asp?' + query.value , 'Budget_Griglia' , '' );
		ExecFunction( 'budget_CambiValute.asp?DO=UPD&IDROW=' + nIdDett + '&VAL=' + val + '&' + query.value , 'budget_CambiValute_Command' , '' );
	}
	catch( e ) {};
	

}

