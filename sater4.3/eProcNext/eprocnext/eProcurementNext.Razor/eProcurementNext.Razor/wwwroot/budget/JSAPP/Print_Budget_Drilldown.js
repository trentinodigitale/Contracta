
function Print_Budget_Drilldown(  )
{
	var query;
	var w;
	var h;
	
	//debugger;
	try {
		
		query = getObj( 'QUERYSTRING' ).value;
		
    
		w = screen.availWidth;
		h = screen.availHeight;

		ExecFunction( 'Print_Budget_DrillDown.asp?OPERATION=PRINT&' + query , 'Budget_Print_Drilldown' , ',menubar=yes,left=0,top=0,width=' + w + ',height=' + h );
	}
	catch( e ) {};
	

}

