
function Budget_NewRevisione( param )
{
	var period;
	var sel;
	
	//debugger;	
	try {
	    var FilterHide  = getObj( 'FILTERHIDE' ).value;

		period = getObj( 'PERIOD' ).value;

		ExecFunction( 'budget_Command.asp?FilterHide=' + FilterHide + '&COMMAND=NEWREVISIONE&PERIOD=' + period + param , 'Budget_Command' , '' );
	}
	catch( e ) {};
	


}

