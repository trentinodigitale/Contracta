
function Budget_Griglia_OnDel( strNameGrid,nIndRow,nIndCol )
{
	var nIdDett;
	
	
	//nIdDett=GetIdRow( strNameGrid , nIndRow , '')
	try {
		
		if( confirm( 'Sei sicuro?' ) )
		{
			nIdDett = getObj( strNameGrid + '_idRow_' + nIndRow ).value;
			var module = getObj( 'MODULE' ).value;

			ExecFunction( 'Budget_Command.asp?MODULE=' + module + '&COMMAND=DEL&IDROW=' + nIdDett  , 'Budget_Command' , '' );
		}
		
	}
	catch( e ) {};
	

}

