function AVCP_CSV( param )
{


	objForm = parent.ViewerFiltro.FormViewerFiltro;
	
	var oldAction = objForm.action;
	var oldtarget = objForm.target;
	
	objForm.action='../AVCP/AVCP_CSV.asp?TitoloFile=' +  param;
	objForm.target='_blank';
	
	objForm.submit();
	
	objForm.action=oldAction; 
	objForm.target=oldtarget;

}