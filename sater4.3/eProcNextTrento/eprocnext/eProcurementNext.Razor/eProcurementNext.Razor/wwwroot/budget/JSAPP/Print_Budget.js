
function Print_Budget(  )
{
	var query;
	var w;
	var h;
	
	//debugger;
	try {
		
		query = getObjPage( 'QUERYSTRING', 'Budget_Griglia' ).value;
		
    
		w = screen.availWidth;
		h = screen.availHeight;

		ExecFunction( 'Print_budget_Griglia.asp?OPERATION=PRINT&' + query , 'Budget_Print' , ',menubar=yes,left=0,top=0,width=' + w + ',height=' + h );
	}
	catch( e ) {};
	

}

