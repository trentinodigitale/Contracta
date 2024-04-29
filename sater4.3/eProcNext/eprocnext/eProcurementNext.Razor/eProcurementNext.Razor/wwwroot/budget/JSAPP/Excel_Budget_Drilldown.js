
function Excel_Budget_Drilldown(  )
{
	var query;
	
	//debugger;
	try {
		
		query = getObj( 'QUERYSTRING' ).value;
		
		var objForm;
	
		objForm = getObj('Budget_Excel'); 
		objForm.action= 'Excel_Budget_DrillDown.asp?OPERATION=EXCEL&' + query ;
		objForm.target='EsportaExcelDrillDown';
		objForm.submit();
	


	}
	catch( e ) {};
	

}

