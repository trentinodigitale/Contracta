
function Budget_Griglia_OnUpd( strNameGrid,nIndRow,nIndCol )
{
	var nIdDett;
	var query;
	
	//debugger;
	//nIdDett=GetIdRow( strNameGrid , nIndRow , '')
	try {
		
		//-- apro la finestra di update
		parent.ShowGroup( 'AddNew' , 0 );
		
		nIdDett = getObj( strNameGrid + '_idRow_' + nIndRow ).value;
		query = getObj( 'QUERYSTRING' ).value;
		
		
		

		ExecFunction( 'Budget_AddNew.asp?MODE=UPD&IDROW=' + nIdDett + '&' + query , 'Budget_AddNew' , '' );
	}
	catch( e ) {};
	

}

