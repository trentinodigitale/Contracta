
function budget_AziendeValute_Griglia_OnUpd( strNameGrid,nIndRow,nIndCol )
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
			val = getObj( 'R'+ nIndRow + '_BDS_CodiceValuta' )[0].value;
		}catch( e ) 
		{
			val = getObj( 'R'+ nIndRow + '_BDS_CodiceValuta' ).value;
		}
		//alert( 'val = ' + val);

		ExecFunction( 'budget_AziendeValute.asp?DO=UPD&IDROW=' + nIdDett + '&VAL=' + val + '&' + query.value , 'budget_AziendeValute' , '' );
	}
	catch( e ) {};
	

}

