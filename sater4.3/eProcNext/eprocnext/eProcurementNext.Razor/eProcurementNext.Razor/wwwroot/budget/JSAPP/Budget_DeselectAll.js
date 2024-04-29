
function Budget_DeselectAll( param )
{
	var query;
	var sel;
	
	//debugger;	
	try {

		query = getObjPage( 'QUERYSTRING', 'Budget_Griglia' ).value;

		ExecFunction( 'Budget_Griglia.asp?COMMAND=DESELECTALL&' + query  , 'Budget_Griglia' , '' );
	}
	catch( e ) {};
	


}

