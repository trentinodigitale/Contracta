
function Budget_Cambi( param )
{
	var query;
	var sel;
	var w = 600;
	var h = 500;
	var Left;
	var Top;

	
	//debugger;	
	try {

		Left = (screen.availWidth-w)/2;
		Top  = (screen.availHeight-h)/2;

		query = getObj( 'PERIOD' ).value;

		ExecFunction( 'budget_CambiValute.asp?PERIOD=' + query + '&' + param , 'budget_CambiValute' , ',left=' + Left + ',top=' + Top + ',width=' + w + ',height=' + h ).focus();
	}
	catch( e ) {};
	
}

