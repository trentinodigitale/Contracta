
function Budget_SelectAll( param )
{
	var query;
	var sel;
	
	//debugger;	
	try {

		query = getObjPage( 'QUERYSTRING', 'Budget_Griglia' ).value;

		ExecFunction( 'Budget_Griglia.asp?COMMAND=SELECTALL&' + query  , 'Budget_Griglia' , '' );
	}
	catch( e ) {};
	
}

