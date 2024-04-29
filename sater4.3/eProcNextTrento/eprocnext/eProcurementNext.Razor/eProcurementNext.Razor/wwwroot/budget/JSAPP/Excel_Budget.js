
function Excel_Budget(  )
{
	var query;
	
	//debugger;
	try {
		
		query = getObjPage( 'QUERYSTRING', 'Budget_Griglia' ).value;
		
		var objForm;
	
		objForm = getObj('Budget_Excel'); 
		objForm.action= 'Excel_budget_Griglia.asp?OPERATION=EXCEL&' + query ;
		objForm.target='EsportaExcel';
		objForm.submit();
	


	}
	catch( e ) {};
	

}

