
function showreport()
{
	

	var DataDA = getObj( 'DataInizio' ).value;
	var DataA = getObj( 'DataFine' ).value;
	

	if (DataDA == '' || DataA == '' )
	{
		
		DMessageBox( '../ctl_library/' , 'Compilare i campi "Data Inizio Periodo di Riferimento?" e "Data Fine Periodo di Riferimento"' , 'Attenzione' , 1 , 400 , 300 ); 
		return false;
	
	}
	
	
	
	return true;

}
